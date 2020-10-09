//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

private class TLActionView: UIView {
  private let label = UILabel()

  init(action: TLAlertAction) {
    super.init(frame: .zero)

    self.translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .green

    addSubview(label)
    label.text = action.title
    label.textColor = .red
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class TLActionController: UIViewController, UIViewControllerTransitioningDelegate {

  /* corner radius = 13 */
  /* item height 57 */
  /* 8 padding on sides */

  let stackViewContainer = UIView()

  let stackView = UIStackView()

  private var actions: [TLAlertAction] = []

  private var cancelAction: TLAlertAction?

  private var detailsTransitioningDelegate = TLDimmedModalTransitioningDelegate()

  init() {
    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .custom
    self.transitioningDelegate = detailsTransitioningDelegate

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .equalCentering
    stackView.alignment = .bottom

    stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.layer.cornerRadius = 13
    stackViewContainer.clipsToBounds = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.addSubview(stackViewContainer)
    stackViewContainer.addSubview(stackView)

    view.superview?.backgroundColor = UIColor.black.withAlphaComponent(0.7)

    stackViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
    stackViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
    stackViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    stackViewContainer.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    stackViewContainer.backgroundColor = .orange

    stackView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: stackViewContainer.trailingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: stackViewContainer.bottomAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: stackViewContainer.topAnchor).isActive = true
    buildActionViews()
  }

  private func buildActionViews() {
    for action in actions {
      let actionView = TLActionView(action: action)
      stackView.addArrangedSubview(actionView)
      actionView.heightAnchor.constraint(equalToConstant: 57).isActive = true
      actionView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
  }

  public func addAction(_ action: TLAlertAction) {
    if action.style == .cancel {
      assert(
          self.cancelAction == nil,
          "TLActionController can only have one action with a style of TLAlertActionCancel"
      )

      cancelAction = action
    } else {
      actions.append(action)
    }
  }

  internal func invokeCancelAction() {
    guard let cancelAction = self.cancelAction else {
      return
    }

    cancelAction.handler?(cancelAction)
    self.dismiss(animated: true)
  }
}
