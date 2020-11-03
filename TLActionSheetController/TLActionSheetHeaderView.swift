//
// Created by Terry Lewis on 12/10/20.
//

import Foundation
import UIKit

class TLActionSheetHeaderView: UIView {
  private static let padding: CGFloat = 14.666
  private static let interLabelSpacing: CGFloat = 12.333
  private static let extendedPadding: CGFloat = 24.666

  private let titleLabel = UILabel()
  private let messageLabel = UILabel()
  private let stackView = UIStackView()

  internal var bottomConstraint: NSLayoutConstraint?

  lazy var visualEffectView: UIView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)
    if #available(iOS 13.0, *) {
      let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
      return UIVisualEffectView(effect: vibrancyEffect)
    } else {
      return UIView(frame: .zero)
    }
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(title: NSAttributedString?, message: NSAttributedString?) {
    super.init(frame: .zero)

    if let visualEffectView = self.visualEffectView as? UIVisualEffectView {
      visualEffectView.contentView.addSubview(stackView)
      visualEffectView.contentView.addSubview(titleLabel)
      visualEffectView.contentView.addSubview(messageLabel)
    } else {
      visualEffectView.addSubview(stackView)
      visualEffectView.addSubview(titleLabel)
      visualEffectView.addSubview(messageLabel)
      backgroundColor = .white
    }

    addSubview(visualEffectView)

    setTitleLabelText(attributedString: title)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    stackView.addArrangedSubview(titleLabel)

    setMessageLabelText(attributedString: message)
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    stackView.addArrangedSubview(messageLabel)

    stackView.spacing = TLActionSheetHeaderView.interLabelSpacing
    stackView.axis = .vertical

    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.translatesAutoresizingMaskIntoConstraints = false

    visualEffectView.topAnchor.constraint(equalTo: topAnchor, constant: TLActionSheetHeaderView.padding).isActive = true
    visualEffectView.leftAnchor.constraint(equalTo: leftAnchor, constant: TLActionSheetHeaderView.padding).isActive = true
    visualEffectView.rightAnchor.constraint(
        equalTo: rightAnchor,
        constant: -TLActionSheetHeaderView.padding
    ).isActive = true
    bottomConstraint = visualEffectView.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -TLActionSheetHeaderView.padding
    )
    bottomConstraint?.isActive = true

    stackView.topAnchor.constraint(equalTo: visualEffectView.topAnchor).isActive = true
    stackView.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor).isActive = true
    stackView.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor).isActive = true

    titleLabel.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor).isActive = true

    messageLabel.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor).isActive = true
    messageLabel.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor).isActive = true
  }

  func setHasActionViewsBelow(_ hasViewBelow: Bool) {
    bottomConstraint?.constant = hasViewBelow ? -TLActionSheetHeaderView.extendedPadding : -TLActionSheetHeaderView.padding
    setNeedsUpdateConstraints()
  }

  private func setTitleLabelText(attributedString: NSAttributedString?) {
    titleLabel.attributedText = attributedString
    titleLabel.isHidden = titleLabel.attributedText == nil
  }

  private func setMessageLabelText(attributedString: NSAttributedString?) {
    messageLabel.attributedText = attributedString
    messageLabel.isHidden = messageLabel.attributedText == nil
  }
}
