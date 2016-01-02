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

@synthesize controllers;
@synthesize board;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize boardSize = CGSizeMake(screenRect.size.width,
                                  screenRect.size.height - tabBarController.tabBar.bounds.size.height);

    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
    [[navController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [controllers addObject:navController];
    [navController release];
    
    navController = [[UINavigationController alloc] initWithRootViewController:photoController];
    [[navController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [controllers addObject:navController];
    [navController release];
    
    navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [navController setNavigationBarHidden:YES];
    [controllers addObject:navController];
    [navController release];
    
    [boardController release];
    [photoController release];
    [settingsController release];
    
    [tabBarController setViewControllers:controllers];
    
    [window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
        
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