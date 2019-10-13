@interface NSDictionary (NSDictionaryAdditions)
- (id)objectForKeyNotNull:(NSString*)key;
@end

@interface UIColor (UIColorAdditions)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha;
@end

@interface NSDate (NSDateAdditions)
- (NSDate *)truncateSeconds;
- (NSDate *)roundToMinuteInterval:(NSInteger)minuteInterval;
- (NSDate *)roundDownToMinuteInterval:(NSInteger)minuteInterval;
- (NSDate *)roundUpToMinuteInterval:(NSInteger)minuteInterval;
+ (NSDate *)today;
- (NSDate *)addDay:(NSInteger)day;
- (NSDate *)addSecond:(NSInteger)second;
@end

@interface UIBarButtonItem (UIBarButtonItemAdditions)
- (void) setFont:(UIFont *)font highlightedFont:(UIFont *)highlightedFont;
@end
