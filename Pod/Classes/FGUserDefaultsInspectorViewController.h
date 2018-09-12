#import <UIKit/UIKit.h>


@interface FGUserDefaultsInspectorViewController : UITableViewController

/**
 * @param suiteName the suite name of the user defaults object to inspect
 * use of the default initializer for this VC will use standardUserDefaults
 */
- (instancetype)initWithSuiteName:(NSString *)suiteName;

/**
 * create an VC for inspecting standardUserDefaults (called when [[FGUserDefaultsInspectorViewController alloc] init] is used)
 */
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

@end
