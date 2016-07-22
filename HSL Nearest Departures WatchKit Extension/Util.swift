//
//  Util.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/07/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import WatchKit

extension WKInterfaceController {
    func presentAlert(title: String, message: String) {
        let alertAction = WKAlertAction(title: "OK", style: WKAlertActionStyle.Default, handler: {() in })
        self.presentAlertControllerWithTitle(title, message: message, preferredStyle: WKAlertControllerStyle.Alert, actions: [alertAction])
    }
}
