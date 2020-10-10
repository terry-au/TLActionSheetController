//
// Created by Terry Lewis on 10/10/20.
//

import Foundation
import UIKit

private class TLActionSeparatorView: UIView {
  lazy var visualEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style(rawValue: 1200) ?? .dark)
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .separator)

    return UIVisualEffectView(effect: vibrancyEffect)
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.contentView.backgroundColor = .white
    addSubview(visualEffectView)

    visualEffectView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    visualEffectView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
  }
}

private class TLActionView: UIControl {
  static let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

  private let label = UILabel()

  private let effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .tertiaryFill)

  private let overlay = UIView()

  internal let action: TLAlertAction

  private lazy var overlayEffectView: UIVisualEffectView! = {
    UIVisualEffectView(effect: effect)
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(action: TLAlertAction) {
    self.action = action
    super.init(frame: .zero)

    self.translatesAutoresizingMaskIntoConstraints = false
    overlayEffectView.translatesAutoresizingMaskIntoConstraints = false

    isUserInteractionEnabled = true

    label.font = (action.style == .cancel) ? .systemFont(ofSize: 20, weight: .semibold) : .systemFont(ofSize: 20)
    label.text = action.title
    label.textColor = (action.style == .destructive) ? .systemRed : .systemBlue

    overlay.isHidden = true
    overlay.backgroundColor = .white
    overlay.translatesAutoresizingMaskIntoConstraints = false

    overlayEffectView.contentView.addSubview(overlay)

    addSubview(overlayEffectView)
    addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    overlay.topAnchor.constraint(equalTo: overlayEffectView.topAnchor).isActive = true
    overlay.bottomAnchor.constraint(equalTo: overlayEffectView.bottomAnchor).isActive = true
    overlay.leadingAnchor.constraint(equalTo: overlayEffectView.leadingAnchor).isActive = true
    overlay.trailingAnchor.constraint(equalTo: overlayEffectView.trailingAnchor).isActive = true

    overlayEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    overlayEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    overlayEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    overlayEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    self.frame.contains(point)
  }

  func setHighlighted(_ highlighted: Bool, impact: Bool = false) {
    if impact && highlighted && self.isHighlighted != highlighted {
      TLActionView.impactFeedbackGenerator.impactOccurred()
    }
    overlay.isHidden = !highlighted
    isHighlighted = highlighted
  }
}

internal class TLActionControllerView: UIView {
  let actionStackView = UIStackView()

  let backgroundEffect = UIBlurEffect(style: UIBlurEffect.Style(rawValue: 1200) ?? .dark)

  internal var actions: [TLAlertAction] = []

  internal var cancelAction: TLAlertAction?

  internal weak var controller: TLActionController?

  internal var header: UIView?

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
      if actions.first !== action || self.header != nil {
        let separatorView = TLActionSeparatorView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        actionStackView.addArrangedSubview(separatorView)
        separatorView.heightAnchor.constraint(equalToConstant: 0.33).isActive = true
        separatorView.widthAnchor.constraint(equalTo: actionStackView.widthAnchor).isActive = true
      }

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
          row.setHighlighted(true, impact: true)
        } else {
          row.setHighlighted(false)
        }
      }
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for row in controlledViews {
      for touch in touches {
        if row.point(inside: touch.location(in: self), with: event) {
          row.setHighlighted(true)
        }
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for row in controlledViews {
      for touch in touches {
        if row.point(inside: touch.location(in: self), with: event) {
          controller?.invoke(action: row.action)
        }
        row.setHighlighted(false)
      }
    }
  }
}
