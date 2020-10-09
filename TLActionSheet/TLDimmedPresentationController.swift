//
// Created by Terry Lewis on 9/10/20.
//

import Foundation
import UIKit

private class TLDimmedPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate {

  private lazy var tapGestureRecognizer: UITapGestureRecognizer! = {
    UITapGestureRecognizer(target: self, action: #selector(onTapDimView(sender:)))
  }()

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView,
          let transitionCoordinator = presentingViewController.transitionCoordinator else {
      return
    }

    if tapGestureRecognizer.view != containerView {
      containerView.isUserInteractionEnabled = true
      containerView.addGestureRecognizer(tapGestureRecognizer)
    }

    containerView.backgroundColor = .clear

    transitionCoordinator.animate(alongsideTransition: { [weak self] context in
      containerView.backgroundColor = UIColor.black.withAlphaComponent(0.48)
    }, completion: nil)
  }

  override func dismissalTransitionWillBegin() {
    guard let containerView = containerView,
          let transitionCoordinator = presentingViewController.transitionCoordinator else {
      return
    }

    transitionCoordinator.animate(alongsideTransition: { [weak self] context in
      containerView.backgroundColor = .clear
    }, completion: nil)
  }

  @objc func onTapDimView(sender: Any?) {
    self.presentedViewController.dismiss(animated: true)
  }
}

private class TLTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let presenting: Bool

  init(presenting: Bool) {
    self.presenting = presenting

    super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let containerView = transitionContext.containerView

    let animationDuration = transitionDuration(using: transitionContext)

    guard let actionController = presenting ? (toViewController as? TLActionController) : (
        fromViewController as? TLActionController
    ) else {
      return
    }

    /* Trigger layout to obtain accurate size of stackViewContainer. */
    actionController.view.setNeedsLayout()
    actionController.view.layoutIfNeeded()


    let offset = CGFloat(100)

    if presenting {
      toViewController.view.transform = CGAffineTransform(
          translationX: 0,
          y: actionController.stackViewContainer.frame.height + offset
      )
      containerView.addSubview(toViewController.view)
    }

    UIView.animate(withDuration: animationDuration, animations: {
      if self.presenting {
        toViewController.view.transform = CGAffineTransform.identity
      } else {
        fromViewController.view.transform = CGAffineTransform(
            translationX: 0,
            y: actionController.stackViewContainer.frame.height + offset
        )
      }
    }, completion: { finished in
      transitionContext.completeTransition(finished)
    })
  }
}

final class TLDimmedModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  func presentationController(
      forPresented presented: UIViewController,
      presenting: UIViewController?,
      source: UIViewController
  ) -> UIPresentationController? {
    TLDimmedPresentationController(presentedViewController: presented, presenting: presenting)
  }

  func animationController(
      forPresented presented: UIViewController,
      presenting: UIViewController,
      source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    TLTransitionAnimator(presenting: true)
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    TLTransitionAnimator(presenting: false)
  }
}
