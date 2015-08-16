//
//  Y_TilesAppDelegate.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/23/09.
//  Copyright Chris Yunker 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "BoardController.h"
#import "PhotoController.h"
#import "SettingsController.h"
#import "Board.h"

@interface AppDelegate ()

@end


@implementation AppDelegate

@synthesize controllers;
@synthesize board;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	controllers = [[NSMutableArray alloc] init];
	
	board = [[Board alloc] init];
	
	BoardController *boardController = [[BoardController alloc] initWithBoard:board];
	PhotoController *photoController = [[PhotoController alloc] initWithBoard:board];
	SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsView" bundle:nil board:board];
	
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
	[[navController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
	[controllers addObject:navController];
	[navController release];
		
	[boardController release];
	[photoController release];
	[settingsController release];
	
	UITabBarController *tabBarController = [[UITabBarController alloc] init];
	[tabBarController setViewControllers:controllers];
		
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	[board createNewBoard];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog("applicationDidEnterBackground");
    [board saveBoard];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog("applicationWillTerminate");
    [board saveBoard];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	DLog("applicationDidReceiveMemoryWarning");
}


@end
