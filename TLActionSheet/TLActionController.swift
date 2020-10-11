//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

class TLActionController: UIViewController, UIViewControllerTransitioningDelegate {
  private var detailsTransitioningDelegate = TLDimmedModalTransitioningDelegate()

  private var cancelAction: TLAlertAction?

  lazy var contentView: UIView! = {
    actionView
  }()

  lazy private var actionView: TLActionControllerView! = {
    let actionView = TLActionControllerView(actionController: self)
    actionView.controller = self

    return actionView
  }()

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
    action.sideEffect = {
      self.dismiss(animated: true)
    }

    if action.style == .cancel {
      cancelAction = action
      print(cancelAction)
    }

    actionView.addAction(action)
  }

  internal func invokeCancelAction() {
    guard let cancelAction = self.cancelAction else {
      return
    }

    cancelAction.invoke()
  }
}
