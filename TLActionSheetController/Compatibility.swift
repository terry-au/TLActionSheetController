//
// Created by Terry Lewis on 17/10/20.
//

import Foundation
import UIKit

internal extension UIColor {
  static func themed(isDarkMode: @escaping (Bool) -> UIColor) -> UIColor {
    let lightColour = isDarkMode(false)
    if #available(iOS 13.0, *) {
      let darkColour = isDarkMode(true)

      return self.init(dynamicProvider: { collection in
        if collection.userInterfaceStyle == .dark {
          return darkColour
        }
        return lightColour
      })
    } else {
      return lightColour
    }
  }
}

internal extension UIBlurEffect.Style {
  static var actionSheetStyle: UIBlurEffect.Style! = {
    if #available(iOS 13.0, *) {
      return .systemMaterial
    }

    return .extraLight
  }()
}
