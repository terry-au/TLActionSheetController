//
// Created by Terry Lewis on 11/10/20.
//

import Foundation
import UIKit

private class TLActionView: UIControl {
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

  private lazy var effect: UIVibrancyEffect! = {
    if #available(iOS 13.0, *) {
      let blurEffect = UIBlurEffect(style: .systemMaterial)
      return UIVibrancyEffect(blurEffect: blurEffect, style: .tertiaryFill)
    } else {
      let blurEffect = UIBlurEffect(style: .light)
      return UIVibrancyEffect(blurEffect: blurEffect)
    }
  }()

  private let overlay = UIView()

  internal let action: TLActionSheetAction

  private lazy var overlayEffectView: UIVisualEffectView! = {
    UIVisualEffectView(effect: effect)
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(action: TLActionSheetAction) {
    self.action = action
    super.init(frame: .zero)

    overlayEffectView.translatesAutoresizingMaskIntoConstraints = false

    isUserInteractionEnabled = true

    label.font = (action.style == .cancel) ? .systemFont(ofSize: 20, weight: .semibold) : .systemFont(ofSize: 20)
    label.text = action.title
    label.textColor = (action.style == .destructive) ? TLActionView.destructiveLabelColour : TLActionView.labelColour


    if action.style == .cancel {
      let cancelBgView = UIView()
      cancelBgView.backgroundColor = TLActionView.cancelBackgroundColour
      cancelBgView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(cancelBgView)

      cancelBgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      cancelBgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      cancelBgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      cancelBgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
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

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    self.frame.contains(point)
  }

  func setHighlighted(_ highlighted: Bool, impact: Bool = false) {
    if impact && highlighted && self.isHighlighted != highlighted {
      TLActionView.selectionFeedbackGenerator.selectionChanged()
    }
    overlay.isHidden = !highlighted
    isHighlighted = highlighted
  }
}

private class TLActionSeparatorView: UIView {
  lazy var visualEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)

    if #available(iOS 13.0, *) {
      let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .separator)
      return UIVisualEffectView(effect: vibrancyEffect)
    } else {
      return UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
    }
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


class TLActionGroupView: UIView {

  let actionStackView = UIStackView()

  private var controlledViews = Set<TLActionView>()

  internal var actions: [TLActionSheetAction] = []

  internal var header: UIView?

  let backgroundEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)

  lazy var actionStackViewContainer: UIVisualEffectView! = {
    let visualEffectView = UIVisualEffectView(effect: self.backgroundEffect)

    return visualEffectView
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(frame: .zero)

    self.translatesAutoresizingMaskIntoConstraints = false

    actionStackView.translatesAutoresizingMaskIntoConstraints = false
    actionStackView.axis = .vertical
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

  func addAction(_ action: TLActionSheetAction) {
    actions.append(action)
  }

  internal func prepareForDisplay() {
    if let header = self.header {
      if let actionSheetHeader = header as? TLActionSheetHeader {
        actionSheetHeader.setHasActionViewsBelow(actions.count > 0)
      }
      actionStackView.addArrangedSubview(header)
      header.widthAnchor.constraint(equalTo: actionStackView.widthAnchor).isActive = true
    }

    for action in actions {
      if actions.first !== action || header != nil {
        addSeparator()
      }

      let actionView = TLActionView(action: action)
      actionStackView.addArrangedSubview(actionView)
      actionView.heightAnchor.constraint(equalToConstant: 57).isActive = true
      actionView.widthAnchor.constraint(equalTo: actionStackView.widthAnchor).isActive = true
      self.controlledViews.insert(actionView)
    }
  }

  private func addSeparator() {
    let separatorView = TLActionSeparatorView()
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    actionStackView.addArrangedSubview(separatorView)
    separatorView.heightAnchor.constraint(equalToConstant: 0.33).isActive = true
    separatorView.widthAnchor.constraint(equalTo: actionStackView.widthAnchor).isActive = true
  }

  internal func handleTouchMoved(_ touch: UITouch, with event: UIEvent?) {
    for row in controlledViews {
      if row.point(inside: touch.location(in: self), with: event) {
        row.setHighlighted(true, impact: true)
      } else {
        row.setHighlighted(false)
      }
    }
  }

  internal func handleTouchBegan(_ touch: UITouch, with event: UIEvent?) {
    for row in controlledViews {
      if row.point(inside: touch.location(in: self), with: event) {
        row.setHighlighted(true)
      }
    }
  }

  internal func handleTouchesEnded(_ touch: UITouch, with event: UIEvent?) {
    for row in controlledViews {
      if row.point(inside: touch.location(in: self), with: event) {
        row.action.invoke()
      }
      row.setHighlighted(false)
    }
  }
}
