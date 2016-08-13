import WatchKit
import Foundation
import WatchConnectivity

public class NearestStopsInterfaceController: WKInterfaceController, WCSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet var nearestStopsTable: WKInterfaceTable!
    @IBOutlet var loadingIndicatorLabel: WKInterfaceLabel!

    var nearestStops = [Stop]()

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    override public func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = table.rowControllerAtIndex(rowIndex) as! NearestStopsRow

        self.pushControllerWithName("NextDeparturesInterfaceController", context: ["stopCode": row.code])
    }

    override public func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.initTimer()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            requestLocation()
        }
    }

    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        requestLocation()
    }

    func requestLocation() {
        showLoadingIndicator()
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied) {
            NSLog("Requesting location")
            locationManager.requestLocation()
        }
    }

    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location Manager error: " + error.localizedDescription)
        requestLocation()
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("New location data received")
        let lat = locations.last!.coordinate.latitude
        let lon = locations.last!.coordinate.longitude

        HSL.getNearestStops(lat, lon: lon, successCallback: updateInterface)
    }

    private func updateInterface(nearestStops: [Stop]) -> Void {
        NSLog("Updating Nearest Stops interface")

        loadingIndicatorLabel.setHidden(true)
        hideLoadingIndicator()
        self.nearestStops = nearestStops
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")

        if(nearestStops.count == 0) {
            self.presentAlert(Const.NO_STOPS_TITLE, message: Const.NO_STOPS_MSG)
        } else {
            var i: Int = 0
            for stop in nearestStops {
                let row: AnyObject? = nearestStopsTable.rowControllerAtIndex(i)
                let nearestStopRow = row as! NearestStopsRow

                nearestStopRow.code = stop.codeLong
                nearestStopRow.stopName.setText(stop.name)
                nearestStopRow.stopCode.setText(stop.codeShort)
                nearestStopRow.distance.setText(String(stop.distance) + " m")
                i += 1
            }
        }
    }

    override public func willDisappear() {
        invalidateTimer()
    }

    override public func willActivate() {
        requestLocation()
    }

    private func showLoadingIndicator() {
        initTimer()
        self.loadingIndicatorLabel.setHidden(false)
    }

    private func hideLoadingIndicator() {
        self.loadingIndicatorLabel.setHidden(true)
    }

    @IBAction func refreshClick() {
        requestLocation()
    }

    var counter = 1
    var timer: NSTimer? = NSTimer()

    func initTimer() {
        invalidateTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(NearestStopsInterfaceController.updateLoadingIndicatorText), userInfo: nil, repeats: true)
        self.timer?.fire()
    }

    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc private func updateLoadingIndicatorText() {
        self.counter == 3 ? (self.counter = 1) : (self.counter = self.counter + 1)
        var dots = ""
        for _ in 1...counter {
            dots.append(Character("."))
        }
        self.loadingIndicatorLabel.setText(dots)
    }
}
