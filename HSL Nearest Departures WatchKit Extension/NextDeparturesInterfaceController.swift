import WatchKit
import Foundation
import WatchConnectivity

class NextDeparturesInterfaceController: WKInterfaceController, WCSessionDelegate {

    var connectivitySession: WCSession?

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        session = WCSession.defaultSession()
        if let rootInterfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController,
        let session = rootInterfaceController.session {
            connectivitySession = session
        }

        if let code = context!["stopCode"] as? String {
            session?.sendMessage(
                ["stopCode": code],
                replyHandler: {message in
                    self.updateView(self.nextDeparturesFromWatchConnectivityMessage(message))
                },
                errorHandler: {m in NSLog("Error getting next departures from companion app")})
        }
    }

    private func nextDeparturesFromWatchConnectivityMessage(message: [String: AnyObject]) -> [Departure] {
        if let depsDict = message["nextDepartures"] as? [[String: AnyObject]] {
            var deps: [Departure] = []

            depsDict.forEach({dict in
                if let line = dict["line"] as? String,
                let time = dict["time"] as? String,
                let lineShort = dict["lineShort"] as? String {
                    let dep = Departure(
                        line: line,
                        time: time,
                        lineShort: (lineShort == "") ? nil : lineShort
                    )
                    deps.append(dep)
                }
            })
            return deps
        } else {
            return []
        }
    }

    private func updateView(nextDepartures: [Departure]) -> Void {
        NSLog("Update view")
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        var i: Int = 0
        for departure in nextDepartures {
            let row: AnyObject? = nextDeparturesTable.rowControllerAtIndex(i)
            let nextDepartureRow = row as! NextDeparturesRow
            nextDepartureRow.time.setText(departure.time)
            nextDepartureRow.code.setText(departure.lineShort != nil ? departure.lineShort : departure.line)
            i += 1
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
