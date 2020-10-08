//
// Created by Terry Lewis on 8/10/20.
//

import Foundation
import UIKit

public class TLAlertAction {
  public enum Style: Int {
    case `default` = 0

    case cancel = 1

    case destructive = 2
  }

  open var title: String?

  open var isEnabled: Bool

  fileprivate var style: Style

  private var handler: ((UIAlertAction) -> Void)?

  init(title: String?, style: TLAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) {
    self.title = title
    self.handler = handler
    self.style = style
    isEnabled = true
  }
}

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

class TLActionController: UIViewController {

  /* corner radius = 13 */
  /* item height 57 */
  /* 8 padding on sides */
  private let stackView = UIStackView()

  private var actions: [TLAlertAction] = []

  private var cancelAction: TLAlertAction?

  init() {
    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .overFullScreen
    stackView.translatesAutoresizingMaskIntoConstraints = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(stackView)
    view.superview?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    stackView.axis = .vertical
    stackView.distribution = .equalCentering
    stackView.alignment = .bottom
    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    stackView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    buildActionViews()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    self.transitionCoordinator?.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)

    guard let transitionCoordinator = self.transitionCoordinator else {
      return
    }

    transitionCoordinator.containerView.wantsLae
    transitionCoordinator.containerView.layer.backgroundColor = UIColor.red.cgColor
  }

//  override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//    self.transitionCoordinator?.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//  }

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
}
