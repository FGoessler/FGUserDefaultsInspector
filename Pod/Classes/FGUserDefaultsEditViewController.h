#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FGUserDefaultsEditViewController;

@protocol FGUserDefaultsEditViewControllerDelegate <NSObject>
-(void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atKey:(id)key;
@optional
-(void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atIndex:(NSUInteger)index;
@end

@interface FGUserDefaultsEditViewController : UITableViewController

@property (nonatomic, weak) id<FGUserDefaultsEditViewControllerDelegate> delegate;

- (instancetype)initWithKey:(id)key value:(id)value;
- (instancetype)initWithIndex:(NSUInteger)index value:(id)value;

@end
