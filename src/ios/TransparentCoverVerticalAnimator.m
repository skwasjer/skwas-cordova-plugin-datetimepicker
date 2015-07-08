//
//  TransparentCoverVerticalAnimator.m
//  Qlinx
//
//  Created by Qlinx Mini on 29/09/14.
//
//

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
        
//        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        toViewController.view.frame = CGRectMake(0, 0, 0, 0);
        
        CGPoint startingPoint = [self getStartingPoint:fromViewController.interfaceOrientation];
        if (UIInterfaceOrientationIsPortrait(fromViewController.interfaceOrientation))
        {
            toViewController.view.frame = CGRectMake(startingPoint.x, startingPoint.y,
                                                         fromViewController.view.frame.size.width,
                                                         fromViewController.view.frame.size.height);
        }
        else
        {
            toViewController.view.frame = CGRectMake(startingPoint.x, startingPoint.y,
                                                         fromViewController.view.frame.size.height,
                                                         fromViewController.view.frame.size.width);
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            //toViewController.view.frame = endFrame;
            CGPoint endingPoint = [self getEndingPoint:fromViewController.interfaceOrientation];
            toViewController.view.frame = CGRectMake(endingPoint.x, endingPoint.y, fromViewController.view.frame.size.width,                                                         fromViewController.view.frame.size.height);
            fromViewController.view.alpha = 0.5f;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect fromFrame = fromViewController.view.frame;
//        [transitionContext.containerView addSubview:toViewController.view];
//        [transitionContext.containerView addSubview:fromViewController.view];
        
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            toViewController.view.alpha = 1.0f;
            
            switch(fromViewController.interfaceOrientation)
            {
                case UIInterfaceOrientationPortrait:
                    fromViewController.view.frame = CGRectMake(0, screenBounds.size.height, fromFrame.size.width, fromFrame.size.height);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    fromViewController.view.frame = CGRectMake(0, screenBounds.size.height * -1, fromFrame.size.width, fromFrame.size.height);
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    fromViewController.view.frame = CGRectMake(screenBounds.size.width, 0, fromFrame.size.width, fromFrame.size.height);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    fromViewController.view.frame = CGRectMake(screenBounds.size.width * -1, 0, fromFrame.size.width, fromFrame.size.height);
                    break;
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}


- (CGPoint)getStartingPoint:(UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGPoint coordinate = CGPointMake(0, 0);
    switch(orientation)
    {
        case UIInterfaceOrientationPortrait:
            coordinate = CGPointMake(0, screenBounds.size.height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            coordinate = CGPointMake(0, screenBounds.size.height * -1);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            coordinate = CGPointMake(screenBounds.size.width, 0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            coordinate = CGPointMake(screenBounds.size.width * -1, 0);
            break;
        default:
            coordinate = CGPointMake(0, screenBounds.size.height);
            break;
    }
    
    return coordinate;
}

- (CGPoint)getEndingPoint:(UIInterfaceOrientation)orientation
{
    //CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGPoint coordinate = CGPointMake(0, 0);
    switch(orientation)
    {
        case UIInterfaceOrientationPortrait:
            coordinate = CGPointMake(0, 0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            coordinate = CGPointMake(0, 0);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            coordinate = CGPointMake(0, 0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            coordinate = CGPointMake(0, 0);
            break;
        default:
            coordinate = CGPointMake(0, 0);
            break;
    }
    
    return coordinate;
}

@end
