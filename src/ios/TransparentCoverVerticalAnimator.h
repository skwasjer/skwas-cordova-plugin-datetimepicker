#import <UIKit/UIKit.h>

@interface TransparentCoverVerticalAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
