//
// Created by Terry Lewis on 1/11/20.
//

import Foundation
import UIKit

internal class TLActionView: UIControl {
  private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

  private static let cancelBackgroundColour = UIColor.themed { collection in
    if collection {
      return UIColor(red: 0.173, green: 0.173, blue: 0.180, alpha: 1)
    }

    return UIColor.white
  }

  private static let labelColour = UIColor.themed { isDarkMode in
    if isDarkMode {
      return UIColor(red: 0.275, green: 0.576, blue: 1, alpha: 1)
    }

    return UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
  }

  private static let destructiveLabelColour = UIColor.themed { isDarkMode in
    if isDarkMode {
      return UIColor(red: 1, green: 0.271, blue: 0.227, alpha: 1)
    }

    return UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1)
  }

  private let label = UILabel()

  private let overlay = UIView()

  private lazy var cancelBackgroundView: UIView! = {
    let cancelBackgroundView = UIView()
    cancelBackgroundView.backgroundColor = TLActionView.cancelBackgroundColour
    cancelBackgroundView.translatesAutoresizingMaskIntoConstraints = false

    return cancelBackgroundView
  }()

  var action: TLActionSheetAction! {
    didSet {
      print(action.title)
      if action.style == .cancel {
        insertSubview(cancelBackgroundView, at: 0)

        cancelBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cancelBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cancelBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cancelBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      } else {
        cancelBackgroundView.removeFromSuperview()
      }

      label.font = (action.style == .cancel) ? .systemFont(ofSize: 20, weight: .semibold) : .systemFont(ofSize: 20)
      label.text = action.title
      label.textColor = (action.style == .destructive) ? TLActionView.destructiveLabelColour : TLActionView.labelColour
    }
  }

  private lazy var overlayEffectView: UIVisualEffectView! = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)
    if #available(iOS 13.0, *) {
      let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .tertiaryFill)
      return UIVisualEffectView(effect: vibrancyEffect)
    } else {
      let blurEffect = UIBlurEffect(style: .extraLight)
      let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
      let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
      vibrancyEffectView.backgroundColor = .white
      return vibrancyEffectView
    }
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience init(action: TLActionSheetAction) {
    self.init()
    setAction(action)
  }

  private func setAction(_ action: TLActionSheetAction) {
    self.action = action
  }

  init() {
    super.init(frame: .zero)

    overlayEffectView.translatesAutoresizingMaskIntoConstraints = false

    isUserInteractionEnabled = true

    if #available(iOS 11.0, *) {

    } else {
      backgroundColor = .white
    }

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

  func setHighlighted(_ highlighted: Bool, impact: Bool = false) {
    if impact && highlighted && self.isHighlighted != highlighted {
      TLActionView.selectionFeedbackGenerator.selectionChanged()
    }
    overlay.isHidden = !highlighted
    isHighlighted = highlighted
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    guard let touch = touches.randomElement() else {
      return
    }

    if point(inside: touch.location(in: self), with: event) {
      setHighlighted(true, impact: true)
    } else {
      setHighlighted(false)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    guard let touch = touches.randomElement() else {
      return
    }

    if point(inside: touch.location(in: self), with: event) {
      setHighlighted(true)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    guard let touch = touches.randomElement() else {
      return
    }

    /*
    HACK: Create a perceptible delay before invoking the action and dismissing the controller.
    The scrubbing interaction automatically produces this delay.
    */
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { () -> () in
      if self.point(inside: touch.location(in: self), with: event) {
        self.action.invoke()
      }

      self.setHighlighted(false)
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    setHighlighted(false)
  }
}
