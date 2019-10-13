#import "Extensions.h"

@implementation NSDictionary (NSDictionaryAdditions)

- (id)objectForKeyNotNull:(NSString*)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    else
        return object;
}

@end

@implementation UIColor (UIColorAdditions)

+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

@end

@implementation NSDate (NSDateAdditions)

- (NSDate *)truncateSeconds {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate *)roundToMinuteInterval:(NSInteger)minuteInterval {
    NSDate *truncatedDate = [self truncateSeconds];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:truncatedDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = (NSInteger)( roundf( (float)(minutes / minuteInterval) ) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:truncatedDate];
    return roundedDate;
}

- (NSDate *)roundDownToMinuteInterval:(NSInteger)minuteInterval {
    NSDate *truncatedDate = [self truncateSeconds];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:truncatedDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = (NSInteger)( floor( (float)(minutes / minuteInterval) ) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:truncatedDate];
    return roundedDate;
}

- (NSDate *)roundUpToMinuteInterval:(NSInteger)minuteInterval {
    NSDate *truncatedDate = [self truncateSeconds];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:truncatedDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = (NSInteger)( ceil( (float)(minutes / minuteInterval) ) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:truncatedDate];
    return roundedDate;
}

+ (NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate *)addDay:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = day;
    return [calendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)addSecond:(NSInteger)second {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.second = second;
    return [calendar dateByAddingComponents:dayComponent toDate:self options:0];
}

@end

@implementation UIBarButtonItem (UIBarButtonItemAdditions)

- (void) setFont:(UIFont *)font highlightedFont:(UIFont *)highlightedFont {
    NSDictionary *buttonFontAppearance = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSDictionary *buttonHighlightedFontAppearance = [NSDictionary dictionaryWithObjectsAndKeys:highlightedFont, NSFontAttributeName, nil];
    [self setTitleTextAttributes:buttonFontAppearance forState:UIControlStateNormal];
    [self setTitleTextAttributes:buttonHighlightedFontAppearance forState:UIControlStateHighlighted];
    [self setTitleTextAttributes:buttonFontAppearance forState:UIControlStateFocused];
    [self setTitleTextAttributes:buttonFontAppearance forState:UIControlStateDisabled];
}

@end
