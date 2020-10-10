//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

class TLActionController: UIViewController, UIViewControllerTransitioningDelegate {
  lazy var contentView: UIView! = {
    actionView
  }()

  lazy private var actionView: TLActionControllerView! = {
    let actionView = TLActionControllerView(actionController: self)
    actionView.controller = self

    return actionView
  }()

  private var actions: [TLAlertAction] {
    get {
      actionView.actions
    }
  }

  private var detailsTransitioningDelegate = TLDimmedModalTransitioningDelegate()

  init() {
    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .custom
    self.transitioningDelegate = detailsTransitioningDelegate

    contentView.translatesAutoresizingMaskIntoConstraints = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.addSubview(actionView)
    actionView.prepareForDisplay()

    contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
    contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
    contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
  }

  public func addAction(_ action: TLAlertAction) {
    if action.style == .cancel {
      assert(
          actionView.cancelAction == nil,
          "TLActionController can only have one action with a style of TLAlertActionCancel"
      )

      actionView.cancelAction = action
    } else {
      actionView.actions.append(action)
    }
  }

  internal func invoke(action: TLAlertAction) {
    action.invoke()
    self.dismiss(animated: true)
  }

  internal func invokeCancelAction() {
    guard let cancelAction = actionView.cancelAction else {
      return
    }

    invoke(action: cancelAction)
  }
}
