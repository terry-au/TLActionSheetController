//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

class TLActionSheetController: UIViewController, UIViewControllerTransitioningDelegate {
  private static let kTopAnchorOffset: CGFloat = 44
  private var detailsTransitioningDelegate = TLDimmedModalTransitioningDelegate()
  private var cancelAction: TLActionSheetAction?
  private var landscapeWidthAnchor: NSLayoutConstraint!
  private var topAnchor: NSLayoutConstraint!
  public var header: TLActionSheetHeaderView?

  lazy var contentView: UIView! = {
    actionView
  }()

  private lazy var actionView: TLActionSheetView! = {
    let actionView = TLActionSheetView(actionController: self)
    actionView.translatesAutoresizingMaskIntoConstraints = false
    actionView.controller = self

    return actionView
  }()

  init() {
    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .custom
    transitioningDelegate = detailsTransitioningDelegate

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

    let header = TLActionSheetHeaderView(title: titleAttributedString, message: messageAttributedString)
    header.translatesAutoresizingMaskIntoConstraints = false
    actionView.setHeader(header)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.addSubview(actionView)

    actionView.prepareForDisplay()

    contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    topAnchor = contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
    topAnchor.isActive = true

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
    landscapeWidthAnchor.priority = .required

    updateContentWidthAnchors(for: traitCollection)
  }

  func updateContentWidthAnchors(`for` traitCollection: UITraitCollection) {
    if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .compact {
      landscapeWidthAnchor.isActive = true
      topAnchor.constant = 0
    } else {
      landscapeWidthAnchor.isActive = false
      topAnchor.constant = TLActionSheetController.kTopAnchorOffset
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
      actionView.cancelAction = action
    } else {
      actionView.addAction(action)
    }
  }

  internal func invokeCancelAction() {
    guard let cancelAction = self.cancelAction else {
      return
    }

    cancelAction.invoke()
  }
}
