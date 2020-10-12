//
// Created by Terry Lewis on 10/10/20.
//

import Foundation
import UIKit

internal class TLActionSheetView: UIView {

  internal weak var controller: TLActionSheetController?

  internal let groupStack = UIStackView()

  private var headerView: UIView?

  private var actionGroupView: TLActionGroupView? {
    didSet {
      guard let actionGroupView = self.actionGroupView else {
        return
      }
      actionGroupView.translatesAutoresizingMaskIntoConstraints = false
      groupStack.insertArrangedSubview(actionGroupView, at: 0)

      actionGroupView.leadingAnchor.constraint(equalTo: groupStack.leadingAnchor).isActive = true
      actionGroupView.trailingAnchor.constraint(equalTo: groupStack.trailingAnchor).isActive = true
    }
  }

  private var cancelActionGroupView: TLActionGroupView? {
    didSet {
      guard let cancelActionGroupView = self.cancelActionGroupView else {
        return
      }
      cancelActionGroupView.translatesAutoresizingMaskIntoConstraints = false
      groupStack.addArrangedSubview(cancelActionGroupView)

      cancelActionGroupView.leadingAnchor.constraint(equalTo: groupStack.leadingAnchor).isActive = true
      cancelActionGroupView.trailingAnchor.constraint(equalTo: groupStack.trailingAnchor).isActive = true
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
    actionGroupView?.prepareForDisplay()
    cancelActionGroupView?.prepareForDisplay()
  }

  func addAction(_ action: TLActionSheetAction) {
    if action.style == .cancel {
      if let cancelActionGroupView = self.cancelActionGroupView ?? TLActionGroupView() {
        cancelActionGroupView.addAction(action)
        self.cancelActionGroupView = cancelActionGroupView
      }
    } else {
      if let actionGroupView = self.actionGroupView ?? TLActionGroupView() {
        actionGroupView.addAction(action)
        self.actionGroupView = actionGroupView
      }
    }
  }

  func setHeader(_ header: UIView?) {
    if let actionGroupView = self.actionGroupView ?? TLActionGroupView() {
      actionGroupView.header = header
      self.actionGroupView = actionGroupView
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.handleTouchMoved(touch, with: event)
      cancelActionGroupView?.handleTouchMoved(touch, with: event)
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.handleTouchBegan(touch, with: event)
      cancelActionGroupView?.handleTouchBegan(touch, with: event)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView?.handleTouchesEnded(touch, with: event)
      cancelActionGroupView?.handleTouchesEnded(touch, with: event)
    }
  }
}
