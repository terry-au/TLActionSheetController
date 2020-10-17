//
// Created by Terry Lewis on 9/10/20.
//

import Foundation
import UIKit

private class TLDimmedPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

  private lazy var tapGestureRecognizer: UITapGestureRecognizer! = {
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapDimView(sender:)))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self

    return gestureRecognizer
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
      containerView.backgroundColor = UIColor.themed { isDarkMode in
        if isDarkMode {
          return UIColor.black.withAlphaComponent(0.48)
        }

        if #available(iOS 13.0, *) {
          return UIColor.black.withAlphaComponent(0.2)
        } else {
          /* Darker pre-iOS 13, as the foreground of the action sheet is white. */
          return UIColor.black.withAlphaComponent(0.4)
        }
      }
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
    guard let actionController = presentedViewController as? TLActionSheetController else {
      return
    }

    actionController.invokeCancelAction()
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    touch.view == containerView || touch.view?.superview == containerView
  }
}

private class TLTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let presenting: Bool

  init(presenting: Bool) {
    self.presenting = presenting

    super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.404
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let containerView = transitionContext.containerView

    let animationDuration = transitionDuration(using: transitionContext)

    guard let actionController = presenting ? (toViewController as? TLActionSheetController) : (
        fromViewController as? TLActionSheetController
    ) else {
      return
    }

    /* Trigger layout to obtain accurate size of stackViewContainer. */
    actionController.view.setNeedsLayout()
    actionController.view.layoutIfNeeded()


    let offset = containerView.safeAreaInsets.bottom

    if presenting {
      toViewController.view.transform = CGAffineTransform(
          translationX: 0,
          y: actionController.contentView.frame.height + offset
      )
      containerView.addSubview(toViewController.view)
    }

    UIView.animate(
        withDuration: 0.404,
        delay: 0,
        usingSpringWithDamping: 600,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {
          if self.presenting {
            toViewController.view.transform = CGAffineTransform.identity
          } else {
            fromViewController.view.transform = CGAffineTransform(
                translationX: 0,
                y: actionController.contentView.frame.height + offset
            )
          }
        },
        completion: { finished in
          transitionContext.completeTransition(finished)
        }
    )
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
