//
// Created by Terry Lewis on 9/10/20.
//

import Foundation
import UIKit

public class TLAlertAction {
  public enum Style: Int {
    case `default` = 0

    case cancel = 1

    case destructive = 2
  }

  open var title: String?

  open var isEnabled: Bool

  var style: Style

  private var handler: ((UIAlertAction) -> Void)?

  init(title: String?, style: TLAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) {
    self.title = title
    self.handler = handler
    self.style = style
    isEnabled = true
  }
}
