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
	[tabBarController setDelegate:boardController];
		
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	[board createNewBoard];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	DLog("applicationWillResignActive [%@]", application);	
	[board saveBoard];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	DLog("applicationWillTerminate [%@]", application);
	[board saveBoard];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	DLog("applicationDidEnterBackground [%@]", application);
	[board saveBoard];	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DLog("applicationWillEnterForeground [%@]", application);
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
	DLog("applicationDidBecomeActive [%@]", application);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	DLog("applicationDidReceiveMemoryWarning [%@]", application);
}

- (void)dealloc
{
	DLog("Delegate Dealloc");

	[board release];
	[controllers release];
    [super dealloc];
}

@end
