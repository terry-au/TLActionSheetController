//
//  ViewController.swift
//  TLActionSheet
//
//  Created by Terry Lewis on 8/10/20.
//

import UIKit

class ViewController: UIViewController {

  let classicButton = UIButton(type: .system)
  let newButton = UIButton(type: .system)

  override func viewDidLoad() {
    super.viewDidLoad()

    classicButton.setTitle("Present UIAlertController", for: .normal)
    classicButton.addTarget(self, action: #selector(openClassic(sender:)), for: .touchUpInside)
    view.addSubview(classicButton)

    classicButton.translatesAutoresizingMaskIntoConstraints = false
    classicButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    classicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

    newButton.setTitle("Present TLActionSheetController", for: .normal)
    newButton.addTarget(self, action: #selector(openNew(sender:)), for: .touchUpInside)
    view.addSubview(newButton)

    newButton.translatesAutoresizingMaskIntoConstraints = false
    newButton.topAnchor.constraint(equalTo: classicButton.bottomAnchor, constant: 8).isActive = true
    newButton.centerXAnchor.constraint(equalTo: classicButton.centerXAnchor).isActive = true
  }

  @objc func openClassic(sender: Any?) {
    let alertController = UIAlertController(
        title: "UIAlertController",
        message: "I am a classic alert controller",
        preferredStyle: .actionSheet
    )

    alertController.addAction(.init(title: "Normal", style: .default))
    alertController.addAction(.init(title: "Destructive", style: .destructive))
    alertController.addAction(.init(title: "Cancel", style: .cancel))

    self.present(alertController, animated: true)
  }

  @objc func openNew(sender: Any?) {
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

    self.present(actionSheet, animated: true)
  }
}

