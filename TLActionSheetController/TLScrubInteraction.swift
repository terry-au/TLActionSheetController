//
// Created by Terry Lewis on 1/11/20.
//

import Foundation
import UIKit

internal protocol TLScrubInteraction {
  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?)
  func scrubbingBegan(_ touch: UITouch, with event: UIEvent?)
  func scrubbingEnded(_ touch: UITouch, with event: UIEvent?)
}
