//
// Created by Terry Lewis on 10/10/20.
//

import Foundation
import UIKit

internal class TLActionSheetView: UIView {

  internal weak var controller: TLActionSheetController?

  internal let groupStack = UIStackView()

  private var headerView: UIView?

  private (set) var hasActions = false

  private lazy var actionGroupView: TLActionGroupView! = {
    let actionGroupView = TLActionGroupView()

    return actionGroupView
  }()

  private var cancelActionView: TLCancelActionView?

  internal var cancelAction: TLActionSheetAction? {
    didSet {
      guard let cancelAction = self.cancelAction else {
        return
      }

      cancelActionView = TLCancelActionView(action: cancelAction)
      cancelActionView?.isUserInteractionEnabled = false
    }
  }

  private var actions: [TLActionSheetAction] = []

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(actionController: TLActionSheetController) {
    super.init(frame: .zero)

    isUserInteractionEnabled = true
    translatesAutoresizingMaskIntoConstraints = false

    groupStack.translatesAutoresizingMaskIntoConstraints = false
    groupStack.spacing = 8
    groupStack.axis = .vertical
    groupStack.alignment = .trailing
    addSubview(groupStack)

    groupStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    groupStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    groupStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
    groupStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  internal func prepareForDisplay() {
    if hasActions {
      groupStack.addArrangedSubview(actionGroupView)
      actionGroupView.translatesAutoresizingMaskIntoConstraints = false
      actionGroupView.leadingAnchor.constraint(equalTo: groupStack.leadingAnchor).isActive = true
      actionGroupView.trailingAnchor.constraint(equalTo: groupStack.trailingAnchor).isActive = true
    }

    if let cancelAction = self.cancelActionView {
      groupStack.addArrangedSubview(cancelAction)

      cancelAction.translatesAutoresizingMaskIntoConstraints = false
      cancelAction.leadingAnchor.constraint(equalTo: groupStack.leadingAnchor).isActive = true
      cancelAction.trailingAnchor.constraint(equalTo: groupStack.trailingAnchor).isActive = true
      cancelAction.heightAnchor.constraint(equalToConstant: 57).isActive = true
    }
  }

  func addAction(_ action: TLActionSheetAction) {
    actionGroupView.addAction(action)
    hasActions = true
  }

  func setHeader(_ header: UIView?) {
//      actionGroupView.header = header
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.scrubbingMoved(touch, with: event)
      cancelActionView?.scrubbingMoved(touch, with: event)
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.scrubbingBegan(touch, with: event)
      cancelActionView?.scrubbingBegan(touch, with: event)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.scrubbingEnded(touch, with: event)
      cancelActionView?.scrubbingEnded(touch, with: event)
    }
  }
}
