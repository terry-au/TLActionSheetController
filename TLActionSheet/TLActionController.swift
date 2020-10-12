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

  var landscapeWidthAnchor: NSLayoutConstraint?

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

    contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true


    let leftPortraitAnchor = contentView.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor, constant: 8)
    leftPortraitAnchor.priority = .defaultLow
    leftPortraitAnchor.isActive = true

    let rightPortraitAnchor = contentView.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: -8)
    rightPortraitAnchor.priority = .defaultLow
    rightPortraitAnchor.isActive = true

    let landscapeCentreXAnchor = contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    landscapeCentreXAnchor.priority = .defaultHigh
    landscapeCentreXAnchor.isActive = true

    landscapeWidthAnchor = contentView.widthAnchor.constraint(equalToConstant: 287)
    landscapeWidthAnchor?.priority = .defaultHigh


    updateContentWidthAnchors(for: traitCollection)
  }

  func updateContentWidthAnchors(`for` traitCollection: UITraitCollection) {
    if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .compact {
      landscapeWidthAnchor?.isActive = true
    } else {
      landscapeWidthAnchor?.isActive = false
    }
  }

  override func willTransition(
      to newCollection: UITraitCollection,
      with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.willTransition(to: newCollection, with: coordinator)
    updateContentWidthAnchors(for: newCollection)
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
