//
// Created by Terry Lewis on 10/10/20.
//

import Foundation
import UIKit

internal class TLActionSheetView: UIView {

  internal weak var controller: TLActionSheetController?
  internal let groupStack = UIStackView()
  internal var cancelAction: TLActionSheetAction? {
    didSet {
      guard let cancelAction = self.cancelAction else {
        return
      }

      cancelActionView = TLCancelActionView(action: cancelAction)
      cancelActionView?.isUserInteractionEnabled = false
    }
  }
  internal var header: UIView? {
    get {
      actionGroupView.header
    }

    set {
      actionGroupView.header = newValue
    }
  }

  private var cancelActionView: TLCancelActionView?
  private var actions: [TLActionSheetAction] = []
  private var actionGroupViewScrollingObserver: NSKeyValueObservation!
  private lazy var actionGroupView: TLActionGroupView! = {
    let actionGroupView = TLActionGroupView()

    actionGroupViewScrollingObserver = actionGroupView.observe(\.scrollingEnabled) { [unowned self] responder, change in
      /* If table is scrollable, compress layout to preserve vertical space. */
      if let header = self.actionGroupView.header as? TLActionSheetHeaderView {
        header.setCompressedVerticalLayoutModeEnabled(responder.scrollingEnabled)
      }
    }

    return actionGroupView
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(actionController: TLActionSheetController) {
    super.init(frame: .zero)

    isUserInteractionEnabled = true

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
    if let header = header as? TLActionSheetHeaderView {
      header.setHasActionViewsBelow(actionGroupView.hasActions)
    }

    if actionGroupView.hasActions || header != nil {
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
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.randomElement() {
      actionGroupView.scrubbingMoved(touch, with: event, container: actionGroupView)

      if let cancelActionView = cancelActionView {
        cancelActionView.scrubbingMoved(touch, with: event, container: cancelActionView)
      }
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
