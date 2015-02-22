
#import "FGAppDelegate.h"

@implementation FGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setObject:@"A string value" forKey:@"test.someString"];
    [[NSUserDefaults standardUserDefaults] setObject:@15 forKey:@"test.someInteger"];
    [[NSUserDefaults standardUserDefaults] setObject:@37.3456f forKey:@"test.someFloat"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"test.someDate"];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"test.someBool"];
    [[NSUserDefaults standardUserDefaults] setObject:@{
            @"a" : @"A nested string value",
            @"b" : @42,
            @"c" : @NO,
            @"d" : [NSDate date],
            @"nested Array" : @[@1, @2, @3],
            @"nested Dictionary" : @{@"str1" : @1, @"str2" : @2, @"str3" : @3}
    }                                         forKey:@"test.someDictionary"];
    [[NSUserDefaults standardUserDefaults] setObject:@[
            @"A nested string value",
            @42,
            @NO,
            [NSDate date],
            @[@1, @2, @3],
            @{@"str1" : @1, @"str2" : @2, @"str3" : @3}
    ]                                         forKey:@"test.someArray"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
