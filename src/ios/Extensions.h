@interface NSDictionary (NSDictionaryAdditions)
- (id)objectForKeyNotNull:(NSString*)key;
@end

@interface NSDate (NSDateAdditions)
- (NSDate *)truncateSeconds;
- (NSDate *)roundToMinuteInterval:(NSInteger)minuteInterval;
@end
