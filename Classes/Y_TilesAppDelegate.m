//
//  Y_TilesAppDelegate.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/23/09.
//  Copyright Chris Yunker 2009. All rights reserved.
//

#import "Y_TilesAppDelegate.h"
#import "Constants.h"
#import "BoardController.h"
#import "PhotoController.h"
#import "SettingsController.h"
#import "Board.h"

@implementation Y_TilesAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
//- (void)applicationDidFinishLaunching:(UIApplication *)application
	
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

- (void)applicationWillTerminate:(UIApplication *)application
{
	DLog("applicationWillTerminate");
	[board saveBoard];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	DLog("applicationDidEnterBackground");
	[board saveBoard];	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	DLog("applicationDidReceiveMemoryWarning");
}

- (void)dealloc
{
	DLog("dealloc");
	[board release];
	[controllers release];
    [super dealloc];
}

@end
