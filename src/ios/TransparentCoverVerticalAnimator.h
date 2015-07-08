//
//  TransparentCoverVerticalAnimator.h
//  Qlinx
//
//  Created by Qlinx Mini on 29/09/14.
//
//

#import <UIKit/UIKit.h>

@interface TransparentCoverVerticalAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
