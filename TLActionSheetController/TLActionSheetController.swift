//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

class TLActionSheetController: UIViewController, UIViewControllerTransitioningDelegate {
  private var detailsTransitioningDelegate = TLDimmedModalTransitioningDelegate()

  private var cancelAction: TLActionSheetAction?

  private var landscapeWidthAnchor: NSLayoutConstraint?

  private var header: TLActionSheetHeader?

  lazy var contentView: UIView! = {
    actionView
  }()

  lazy private var actionView: TLActionSheetView! = {
    let actionView = TLActionSheetView(actionController: self)
    actionView.controller = self

    return actionView
  }()

  init() {
    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .custom
    self.transitioningDelegate = detailsTransitioningDelegate

    contentView.translatesAutoresizingMaskIntoConstraints = false
  }

  convenience init(title: String?, message: String? = nil) {
    self.init()

    let labelColour: UIColor = {
      if #available(iOS 13.0, *) {
        return .label
      } else {
        return UIColor(white: 0.56, alpha: 1)
      }
    }()

    let titleAttributedString = { () -> NSAttributedString? in
      if let title = title {
        return NSAttributedString(
            string: title,
            attributes: [.foregroundColor: labelColour, .font: UIFont.boldSystemFont(ofSize: 13)]
        )
      }
      return nil
    }()

    let messageAttributedString = { () -> NSAttributedString? in
      if let message = message {
        return NSAttributedString(
            string: message,
            attributes: [.foregroundColor: labelColour, .font: UIFont.systemFont(ofSize: 13)]
        )
      }
      return nil
    }()

    header = TLActionSheetHeader(title: titleAttributedString, message: messageAttributedString)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.addSubview(actionView)

    actionView.setHeader(header)
    actionView.prepareForDisplay()

    contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

    let leftPortraitAnchor = contentView.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor, constant: 8)
    leftPortraitAnchor.priority = .defaultHigh
    leftPortraitAnchor.isActive = true

    let rightPortraitAnchor = contentView.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: -8)
    rightPortraitAnchor.priority = .defaultHigh
    rightPortraitAnchor.isActive = true

    let landscapeCentreXAnchor = contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    landscapeCentreXAnchor.priority = .defaultHigh
    landscapeCentreXAnchor.isActive = true

    landscapeWidthAnchor = contentView.widthAnchor.constraint(equalToConstant: 287)
    landscapeWidthAnchor?.priority = .required

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

  public func addAction(_ action: TLActionSheetAction) {
    action.sideEffect = {
      self.dismiss(animated: true)
    }

    if action.style == .cancel {
      cancelAction = action
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
