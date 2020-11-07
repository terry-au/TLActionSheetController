//
//  ViewController.swift
//  TLActionSheet
//
//  Created by Terry Lewis on 8/10/20.
//

import UIKit

class ViewController: UIViewController {

  struct Action {
    let label: String
    let action: Selector

    init(label: String, action: Selector) {
      self.label = label
      self.action = action
    }
  }


  let stackView = UIStackView(frame: .zero)

  override func viewDidLoad() {
    super.viewDidLoad()


    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 16
    view.addSubview(stackView)

    stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true

    [
      Action(label: "UIAlertController", action: #selector(openClassic)),
      Action(label: "TLActionSheetController", action: #selector(openNew)),
      Action(label: "TLActionSheetController + Custom Header", action: #selector(openNewCustomHeader)),
    ].forEach { (action: Action) in
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setContentHuggingPriority(.defaultHigh, for: .vertical)
      button.setTitle(action.label, for: .normal)
      button.addTarget(self, action: action.action, for: .touchUpInside)

      stackView.addArrangedSubview(button)
    }
  }

  @objc func openClassic() {
    let alertController = UIAlertController(
        title: nil, //"UIAlertController",
        message: nil, //"I am a classic alert controller",
        preferredStyle: .actionSheet
    )

    alertController.addAction(.init(title: "Normal", style: .default))
    alertController.addAction(.init(title: "Destructive", style: .destructive))
    alertController.addAction(.init(title: "Cancel", style: .cancel))

    present(alertController, animated: true)
  }

  @objc func openNewCustomHeader() {
    let header = UIView(frame: .zero)

    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.text = """
                 Hello, this is a test header.

                 With multi line support!
                 """

    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Test button", for: .normal)


    header.addSubview(label)
    header.addSubview(button)

    label.topAnchor.constraint(equalTo: header.topAnchor, constant: 16).isActive = true
    label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
    label.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16).isActive = true

    button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16).isActive = true
    button.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
    button.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16).isActive = true
    button.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16).isActive = true

    let actionSheet = TLActionSheetController()
    actionSheet.header = header

    actionSheet.addAction(.init(title: "Normal", style: .default))
    actionSheet.addAction(.init(title: "Destructive", style: .destructive))
    actionSheet.addAction(.init(title: "Cancel", style: .cancel))

    present(actionSheet, animated: true)
  }

  @objc func openNew() {
    let actionSheet = TLActionSheetController(
        title: "TLActionSheetController",
        message: "I am a TLActionSheetController"
    )

    actionSheet.addAction(.init(title: "Normal", style: .default) { action in
      print("Normal tapped!")
    })
    actionSheet.addAction(.init(title: "Destructive", style: .destructive) { action in
      print("Destructive tapped!")
    })
    actionSheet.addAction(.init(title: "Cancel", style: .cancel) { action in
      print("Cancel tapped!")
    })

    present(actionSheet, animated: true)
  }
}

