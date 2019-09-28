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
