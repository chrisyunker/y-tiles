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
    [self configureNavigationBar:navController];
    [controllers addObject:navController];
    
    navController = [[UINavigationController alloc] initWithRootViewController:photoController];
    [self configureNavigationBar:navController];
    [controllers addObject:navController];
    
    navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [navController setNavigationBarHidden:YES];
    [self configureNavigationBar:navController];
    [controllers addObject:navController];
    
    [tabBarController setViewControllers:controllers];
    
    // Configure modern tab bar appearance
    [[tabBarController tabBar] setTranslucent:NO];
    
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]; // Consistent with nav bar
        
        // Configure normal (unselected) state with improved legibility
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor colorWithWhite:0.75 alpha:1.0],
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium]
        };
        appearance.stackedLayoutAppearance.normal.iconColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        
        // Configure selected state with modern accent color
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor systemBlueColor],
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold]
        };
        appearance.stackedLayoutAppearance.selected.iconColor = [UIColor systemBlueColor];
        
        [[tabBarController tabBar] setStandardAppearance:appearance];
        if (@available(iOS 15.0, *)) {
            [[tabBarController tabBar] setScrollEdgeAppearance:appearance];
        }
    } else {
        // Fallback for iOS 12 and earlier
        [[tabBarController tabBar] setBarStyle:UIBarStyleBlack];
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        [[UITabBar appearance] setTintColor:[UIColor systemBlueColor]];
        [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
    }
    
    [self.window setRootViewController:tabBarController];
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)configureNavigationBar:(UINavigationController *)navController
{
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]; // Modern dark gray
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]
        };
        
        navController.navigationBar.standardAppearance = appearance;
        navController.navigationBar.scrollEdgeAppearance = appearance;
        navController.navigationBar.compactAppearance = appearance;
    } else {
        // Fallback for earlier iOS versions
        [[navController navigationBar] setBarStyle:UIBarStyleBlack];
        [[navController navigationBar] setBarTintColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
        [[navController navigationBar] setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor whiteColor]
        }];
    }
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