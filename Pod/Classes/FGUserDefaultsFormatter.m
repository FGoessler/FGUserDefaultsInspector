#import "FGUserDefaultsFormatter.h"


@implementation FGUserDefaultsFormatter

+ (NSString*)descriptionForObject:(id)object {
    if(object == nil) {
        return @"(nil)";
    } else if ([self isBooleanNSNumber:object]) {
        return [object boolValue] ? @"true" : @"false";
    } else if([object isKindOfClass:[NSArray class]]) {
        NSMutableString *arrayString = [@"[" mutableCopy];
        for(id obj in object) {
            if(![arrayString isEqualToString:@"["]) [arrayString appendString:@", "];
            [arrayString appendString:[self descriptionForObject:obj]];
        }
        [arrayString appendString:@"]"];
        return arrayString;
    } else if([object isKindOfClass:[NSDictionary class]]) {
        NSMutableString *dictionaryString = [@"{" mutableCopy];
        for(id key in [object allKeys]) {
            if(![dictionaryString isEqualToString:@"{"]) [dictionaryString appendString:@", "];
            [dictionaryString appendString:[self descriptionForObject:key]];
            [dictionaryString appendString:@":"];
            [dictionaryString appendString:[self descriptionForObject:object[key]]];
        }
        [dictionaryString appendString:@"}"];
        return dictionaryString;
    } else {
        NSString *str = [object description];
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];
        return [regEx stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@" "];
    }
}

+ (NSString*)typeStringForObject:(id)object {
    return [@"Type: " stringByAppendingString:[[object class] description]];
}

+ (BOOL)isBooleanNSNumber:(id)object {
    return [[[object class] description] isEqualToString:@"__NSCFBoolean"];
}

@end
