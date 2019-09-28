#import "Extensions.h"

@implementation NSDictionary (NSDictionaryAdditions)

- (id)objectForKeyNotNull:(NSString*)key
{
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    else
        return object;
}

@end

@implementation NSDate (NSDateAdditions)

- (NSDate *)truncateSeconds
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *fromDateComponents = [gregorian components:unitFlags fromDate:self];
    return [gregorian dateFromComponents:fromDateComponents];
}

- (NSDate *)roundToMinuteInterval:(NSInteger)minuteInterval
{
    NSDate *truncatedDate = [self truncateSeconds];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:truncatedDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:truncatedDate];
    return roundedDate;
}

@end
