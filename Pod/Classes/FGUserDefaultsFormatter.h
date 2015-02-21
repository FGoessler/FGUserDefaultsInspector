#import <Foundation/Foundation.h>


@interface FGUserDefaultsFormatter : NSObject
+ (NSString *)descriptionForObject:(id)object;
+ (NSString *)typeStringForObject:(id)object;
@end
