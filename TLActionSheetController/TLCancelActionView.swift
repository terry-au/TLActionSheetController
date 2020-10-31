//
// Created by Terry Lewis on 1/11/20.
//

import Foundation
import UIKit

internal class TLCancelActionView: UIView, TLScrubInteraction {
  let action: TLActionSheetAction

  let actionView: TLActionView

  required init?(coder: NSCoder) {
    fatalError()
  }

  init(action: TLActionSheetAction) {
    self.action = action
    actionView = TLActionView(action: action)
    super.init(frame: CGRect.zero)

    layer.cornerRadius = 13
    clipsToBounds = true

    actionView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(actionView)
    actionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    actionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    actionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    actionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.setHighlighted(true, impact: true)
    } else {
      actionView.setHighlighted(false)
    }
  }

  func scrubbingBegan(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.setHighlighted(true)
    }
  }

  func scrubbingEnded(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.action.invoke()
    }
    actionView.setHighlighted(false)
  }
}
