//
// Created by Terry Lewis on 10/10/20.
//

import Foundation
import UIKit

private class TLActionView: UIControl {
  private let label = UILabel()

  let overlay = UIView()

  let action: TLAlertAction

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(action: TLAlertAction) {
    self.action = action
    super.init(frame: .zero)

    self.translatesAutoresizingMaskIntoConstraints = false
    overlay.translatesAutoresizingMaskIntoConstraints = false
    overlay.backgroundColor = .red
    overlay.isHidden = true

    isUserInteractionEnabled = true

    label.font = (action.style == .cancel) ? .systemFont(ofSize: 20, weight: .semibold) : .systemFont(ofSize: 20)
    label.text = action.title
    label.textColor = (action.style == .destructive) ? .systemRed : .systemBlue

    addSubview(overlay)
    addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    overlay.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    overlay.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    overlay.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    overlay.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    self.frame.contains(point)
  }
}

internal class TLAlertControllerView: UIView {
  let actionStackView = UIStackView()

  let backgroundEffect = UIBlurEffect(style: .systemMaterial)

  internal var actions: [TLAlertAction] = []

  internal var cancelAction: TLAlertAction?

  private var controlledViews = Set<TLActionView>()

  lazy var actionStackViewContainer: UIVisualEffectView! = {
    let visualEffectView = UIVisualEffectView(effect: self.backgroundEffect)

    return visualEffectView
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(actionController: TLActionController) {
    super.init(frame: .zero)

    self.isUserInteractionEnabled = true

    actionStackView.translatesAutoresizingMaskIntoConstraints = false
    actionStackView.axis = .vertical
    actionStackView.distribution = .equalCentering
    actionStackView.alignment = .bottom
    actionStackView.isUserInteractionEnabled = false

    actionStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    actionStackViewContainer.layer.cornerRadius = 13
    actionStackViewContainer.clipsToBounds = true

    self.addSubview(actionStackViewContainer)

    actionStackViewContainer.contentView.addSubview(actionStackView)

    actionStackViewContainer.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    actionStackViewContainer.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    actionStackViewContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    actionStackViewContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

    actionStackView.leadingAnchor.constraint(equalTo: actionStackViewContainer.leadingAnchor).isActive = true
    actionStackView.trailingAnchor.constraint(equalTo: actionStackViewContainer.trailingAnchor).isActive = true
    actionStackView.bottomAnchor.constraint(equalTo: actionStackViewContainer.bottomAnchor).isActive = true
    actionStackView.topAnchor.constraint(equalTo: actionStackViewContainer.topAnchor).isActive = true
  }

  internal func prepareForDisplay() {
    for action in actions {
      let actionView = TLActionView(action: action)
      actionStackView.addArrangedSubview(actionView)
      actionView.heightAnchor.constraint(equalToConstant: 57).isActive = true
      actionView.widthAnchor.constraint(equalTo: actionStackView.widthAnchor).isActive = true
      self.controlledViews.insert(actionView)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for row in controlledViews {
      for touch in touches {
        if row.point(inside: touch.location(in: self), with: event) {
          row.overlay.isHidden = false
        } else {
          row.overlay.isHidden = true
        }
      }
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for row in controlledViews {
      for touch in touches {
        if row.point(inside: touch.location(in: self), with: event) {
          row.overlay.isHidden = false
        }
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for row in controlledViews {
      for touch in touches {
        if row.point(inside: touch.location(in: self), with: event) {
          row.action.invoke()
        }
        row.overlay.isHidden = true
      }
    }
  }
}
