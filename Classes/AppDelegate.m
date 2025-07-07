//
//  AppDelegate.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/31/15.
//
//

#import "AppDelegate.h"
#import "Constants.h"
#import "BoardController.h"
#import "PhotoController.h"
#import "SettingsController.h"
#import "Board.h"

@implementation AppDelegate

@synthesize window;
@synthesize controllers;
@synthesize board;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize boardSize = CGSizeMake(screenRect.size.width,
                                  screenRect.size.height - tabBarController.tabBar.bounds.size.height);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    controllers = [[NSMutableArray alloc] init];
    
    board = [[Board alloc] initWithSize:boardSize];
    BoardController *boardController = [[BoardController alloc] initWithBoard:board];
    PhotoController *photoController = [[PhotoController alloc] initWithBoard:board];
    SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsView"
                                                                                  bundle:nil
                                                                                   board:board];
    
    // Order tabs going down from left to right
    UINavigationController *navController;
    
    navController = [[UINavigationController alloc] initWithRootViewController:boardController];
    [navController setNavigationBarHidden:YES];
    [[navController navigationBar] setBarStyle:UIBarStyleBlack];
    [controllers addObject:navController];
    
    navController = [[UINavigationController alloc] initWithRootViewController:photoController];
    [[navController navigationBar] setBarStyle:UIBarStyleBlack];
    [controllers addObject:navController];
    
    navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [navController setNavigationBarHidden:YES];
    [[navController navigationBar] setBarStyle:UIBarStyleBlack];
    [controllers addObject:navController];
    
    [tabBarController setViewControllers:controllers];
    
    // Configure tab bar appearance
    [[tabBarController tabBar] setBarStyle:UIBarStyleBlack];
    [[tabBarController tabBar] setTranslucent:NO];
    
    // Make unselected tab bar items more legible
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor blackColor];
        
        // Configure normal (unselected) state - darker text for better readability
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor colorWithWhite:0.7 alpha:1.0]
        };
        appearance.stackedLayoutAppearance.normal.iconColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        
        // Configure selected state - white for contrast
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        appearance.stackedLayoutAppearance.selected.iconColor = [UIColor whiteColor];
        
        [[tabBarController tabBar] setStandardAppearance:appearance];
        if (@available(iOS 15.0, *)) {
            [[tabBarController tabBar] setScrollEdgeAppearance:appearance];
        }
    } else {
        // Fallback for iOS 12 and earlier
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    }
    
    [self.window setRootViewController:tabBarController];
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog("applicationDidEnterBackground");
    [board saveBoard];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog("applicationWillTerminate");
    [board saveBoard];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DLog("applicationDidReceiveMemoryWarning");
}

@end