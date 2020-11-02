//
// Created by Terry Lewis on 11/10/20.
//

import Foundation
import UIKit


private class TLActionSeparatorView: UIView {
  @available(iOS 13.0, *)
  private lazy var visualEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .separator)
    return UIVisualEffectView(effect: vibrancyEffect)
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    if #available(iOS 13.0, *) {
      visualEffectView.translatesAutoresizingMaskIntoConstraints = false
      visualEffectView.contentView.backgroundColor = .white
      addSubview(visualEffectView)

      visualEffectView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
      visualEffectView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    } else {
      backgroundColor = UIColor(red: 0, green: 0, blue: 0.31, alpha: 0.05)
    }
  }
}

final class ContentSizedTableView: UITableView {
  override var contentSize: CGSize {
    didSet {
      invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    layoutIfNeeded()
    return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
  }
}

private class TLActionGroupViewCell: UITableViewCell, TLScrubInteraction {
  private var actionViewBottomConstraint: NSLayoutConstraint!
  private var separatorViewBottomConstraint: NSLayoutConstraint!

  private lazy var actionView: TLActionView! = {
    let actionView = TLActionView()
    actionView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(actionView)

    actionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    actionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    actionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    actionViewBottomConstraint = actionView.bottomAnchor.constraint(equalTo: bottomAnchor)

    return actionView
  }()

  private lazy var separatorView: TLActionSeparatorView = {
    let separatorView = TLActionSeparatorView()
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(separatorView)

    separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    separatorView.topAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
    separatorView.heightAnchor.constraint(equalToConstant: 3 / UIScreen.main.scale).isActive = true
    separatorViewBottomConstraint = separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

    return separatorView
  }()

  internal var isSeparatorHidden = false {
    didSet {
      if isSeparatorHidden {
        separatorView.isHidden = true
        separatorViewBottomConstraint.isActive = false
        actionViewBottomConstraint.isActive = true
      } else {
        separatorView.isHidden = false
        actionViewBottomConstraint.isActive = false
        separatorViewBottomConstraint.isActive = true
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    backgroundColor = nil
  }

  func setAction(action: TLActionSheetAction) {
    actionView.action = action
    actionView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(actionView)
  }

  override func prepareForReuse() {
    super.prepareForReuse()

//    actionViewBottomConstraint.isActive = false
//    separatorView.isHidden = false
  }

  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.setHighlighted(true, impact: true)
    } else {
      actionView.setHighlighted(false)
    }
  }

  func scrubbingBegan(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.setHighlighted(true)
    }
  }

  func scrubbingEnded(_ touch: UITouch, with event: UIEvent?) {
    if point(inside: touch.location(in: self), with: event) {
      actionView.action.invoke()
    }
    actionView.setHighlighted(false)
  }
}

internal class TLActionGroupView: UIView, UITableViewDataSource, UITableViewDelegate, TLScrubInteraction {

  private static let kActionCellIdentifier = "ActionCell"

  private var actions: [TLActionSheetAction] = []

  private var tableContentSizeObserver: NSKeyValueObservation!

  @available(iOS 13.0, *)
  private lazy var separatorEffect: UIVisualEffect = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)
    return UIVibrancyEffect(blurEffect: blurEffect, style: .separator)
  }()

  private lazy var tableView: UITableView = {
    let tableView = ContentSizedTableView(frame: .zero)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alwaysBounceVertical = false
    tableView.backgroundColor = nil
    tableView.rowHeight = 57
    tableView.separatorStyle = .none
    tableView.register(TLActionGroupViewCell.self, forCellReuseIdentifier: TLActionGroupView.kActionCellIdentifier)

    tableContentSizeObserver = tableView.observe(\.contentSize) { [unowned self] responder, change in
      /* If table is scrollable, enable user interaction. */
      self.isUserInteractionEnabled = responder.contentSize.height > responder.bounds.height
    }

    return tableView
  }()

  private lazy var actionStackViewContainer: UIVisualEffectView! = {
    let backgroundEffect = UIBlurEffect(style: UIBlurEffect.Style.actionSheetStyle)
    let visualEffectView = UIVisualEffectView(effect: backgroundEffect)
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false

    return visualEffectView
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.cornerRadius = 13
    clipsToBounds = true

    addSubview(actionStackViewContainer)
    actionStackViewContainer.contentView.addSubview(tableView)

    actionStackViewContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
    actionStackViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    actionStackViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    actionStackViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    tableView.topAnchor.constraint(equalTo: actionStackViewContainer.topAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: actionStackViewContainer.bottomAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: actionStackViewContainer.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: actionStackViewContainer.trailingAnchor).isActive = true
  }

  override func observeValue(
      forKeyPath keyPath: String?,
      of object: Any?,
      change: [NSKeyValueChangeKey: Any]?,
      context: UnsafeMutableRawPointer?
  ) {
    if (object as? UITableView) === tableView && keyPath == "contentSize" {

    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  func addAction(_ action: TLActionSheetAction) {
    actions.append(action)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    actions.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
        withIdentifier: TLActionGroupView.kActionCellIdentifier,
        for: indexPath
    ) as? TLActionGroupViewCell else {
      fatalError("invalid cell returned in TLACtionGroupView")
    }

    let action = actions[indexPath.row]
    cell.setAction(action: action)
    cell.isSeparatorHidden = indexPath.row == actions.count - 1

    return cell
  }

  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?) {
    guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
      return
    }

    for indexPath in indexPathsForVisibleRows {
      guard let cell = tableView.cellForRow(at: indexPath) as? TLActionGroupViewCell else {
        continue
      }

      cell.scrubbingMoved(touch, with: event)
    }
  }

  func scrubbingBegan(_ touch: UITouch, with event: UIEvent?) {
    guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
      return
    }

    for indexPath in indexPathsForVisibleRows {
      guard let cell = tableView.cellForRow(at: indexPath) as? TLActionGroupViewCell else {
        continue
      }

      cell.scrubbingBegan(touch, with: event)
    }
  }

  func scrubbingEnded(_ touch: UITouch, with event: UIEvent?) {
    guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
      return
    }

    for indexPath in indexPathsForVisibleRows {
      guard let cell = tableView.cellForRow(at: indexPath) as? TLActionGroupViewCell else {
        continue
      }

      cell.scrubbingEnded(touch, with: event)
    }
  }
}
