#import "TransparentCoverVerticalAnimator.h"

@implementation TransparentCoverVerticalAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;

        [transitionContext.containerView addSubview:toViewController.view];

        CGRect startRect = fromViewController.view.frame;
        startRect.origin.y += startRect.size.height;
        CGRect endRect = fromViewController.view.frame;
        endRect.origin = CGPointZero;

        // Start animation.
        toViewController.view.frame = startRect;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endRect;
            fromViewController.view.alpha = 0.8f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;

        CGRect startRect = toViewController.view.frame;
        startRect.origin = CGPointZero;
        CGRect endRect = fromViewController.view.frame;
        endRect.origin.y += startRect.size.height;

        // Start animation.
        fromViewController.view.frame = startRect;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endRect;
            toViewController.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
