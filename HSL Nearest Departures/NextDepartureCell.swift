import Foundation
import UIKit

class NextDepartureCell: UITableViewCell {
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var destination: UILabel!

    var codeWidthConstraint: NSLayoutConstraint?
}
