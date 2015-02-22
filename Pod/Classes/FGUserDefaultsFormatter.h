#import <Foundation/Foundation.h>


@interface FGUserDefaultsFormatter : NSObject
+ (NSString *)descriptionForObject:(id)object;
+ (NSString *)typeStringForObject:(id)object;
+ (BOOL)isBooleanNSNumber:(id)object;
@end
