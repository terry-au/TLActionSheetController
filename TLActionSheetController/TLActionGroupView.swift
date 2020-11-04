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

private class TLActionGroupViewCell: UITableViewCell, TLScrubbable {
  private var actionViewBottomConstraint: NSLayoutConstraint!
  private var separatorViewBottomConstraint: NSLayoutConstraint!

  var action: TLActionSheetAction {
    get {
      actionView.action
    }

    set {
      actionView.action = newValue
      actionView.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(actionView)
    }
  }

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
    separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
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

  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?, container: UIView) {
    if point(inside: touch.location(in: self), with: event)
           && container.point(inside: touch.location(in: container), with: event) {
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

internal class TLActionGroupView: UIView, UITableViewDataSource, UITableViewDelegate, TLScrubbable {

  private static let kActionCellIdentifier = "ActionCell"

  var header: UIView? {
    didSet {
      if let oldHeader = oldValue {
        oldHeader.removeFromSuperview()
        headerSeparator.removeFromSuperview()
      }

      if let header = header {
        header.translatesAutoresizingMaskIntoConstraints = false
        containerView.contentView.addSubview(header)
        containerView.contentView.addSubview(headerSeparator)
      }

      updateLayout()
    }
  }

  @objc internal dynamic var scrollingEnabled = false
  internal var hasActions: Bool {
    get {
      !actions.isEmpty
    }
  }

  private var actions: [TLActionSheetAction] = []
  private var tableContentSizeObserver: NSKeyValueObservation!
  private let headerSeparator = TLActionSeparatorView()
  private var dynamicConstraints: [NSLayoutConstraint]! = []

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
    tableView.rowHeight = 57 + (1 / UIScreen.main.scale)
    tableView.separatorStyle = .none
    tableView.register(TLActionGroupViewCell.self, forCellReuseIdentifier: TLActionGroupView.kActionCellIdentifier)

    tableContentSizeObserver = tableView.observe(\.contentSize) { [unowned self] responder, change in
      /* If table is scrollable, enable user interaction and show scrollbars. */
      let scrollingEnabled = responder.contentSize.height > responder.bounds.height
      self.isUserInteractionEnabled = scrollingEnabled
      tableView.showsVerticalScrollIndicator = scrollingEnabled

      self.scrollingEnabled = scrollingEnabled
    }

    return tableView
  }()

  private lazy var containerView: UIVisualEffectView! = {
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

    headerSeparator.translatesAutoresizingMaskIntoConstraints = false

    addSubview(containerView)

    containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    tableView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
  }

  private func updateLayout() {
    /* Invalidate old constraints. */
    NSLayoutConstraint.deactivate(dynamicConstraints)
    dynamicConstraints = []

    let hasTableView = actions.count > 0
    let hasHeader = header != nil

    if hasTableView {
      containerView.contentView.addSubview(tableView)
    } else {
      tableView.removeFromSuperview()
    }

    dynamicConstraints.append(contentsOf: updateTableConstraints(hasHeader: hasHeader))
    dynamicConstraints.append(contentsOf: updateHeaderConstraints(hasTableView: hasTableView))

    NSLayoutConstraint.activate(dynamicConstraints)

    setNeedsUpdateConstraints()
  }

  private func updateTableConstraints(hasHeader: Bool) -> [NSLayoutConstraint] {
    guard tableView.superview === containerView.contentView else {
      return []
    }

    var constraints = [
      tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
    ]

    if !hasHeader {
      constraints.append(tableView.topAnchor.constraint(equalTo: containerView.topAnchor))
    }

    return constraints
  }

  private func updateHeaderConstraints(hasTableView: Bool) -> [NSLayoutConstraint] {
    guard let header = self.header else {
      return []
    }

    var constraints = [
      header.topAnchor.constraint(equalTo: containerView.topAnchor),
      header.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      header.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
    ]

    if hasTableView {
      constraints.append(contentsOf: [
        header.bottomAnchor.constraint(equalTo: tableView.topAnchor),
        headerSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
        headerSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        headerSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        headerSeparator.topAnchor.constraint(equalTo: header.bottomAnchor)
      ])
    } else {
      constraints.append(header.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
    }

    return constraints
  }

  func addAction(_ action: TLActionSheetAction) {
    let needsUpdate = actions.isEmpty

    actions.append(action)

    if needsUpdate {
      updateLayout()
    }
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
    cell.action = action
    cell.isSeparatorHidden = indexPath.row == actions.count - 1

    return cell
  }

  func scrubbingMoved(_ touch: UITouch, with event: UIEvent?, container: UIView) {
    guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
      return
    }

    for indexPath in indexPathsForVisibleRows {
      guard let cell = tableView.cellForRow(at: indexPath) as? TLActionGroupViewCell else {
        continue
      }

      cell.scrubbingMoved(touch, with: event, container: container)
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
