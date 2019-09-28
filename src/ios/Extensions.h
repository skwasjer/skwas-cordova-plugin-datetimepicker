@interface NSDictionary (NSDictionaryAdditions)
- (id)objectForKeyNotNull:(NSString*)key;
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
