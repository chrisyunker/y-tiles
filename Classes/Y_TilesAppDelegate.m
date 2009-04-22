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

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
	Board *board = [[Board alloc] init];
	
	BoardController *boardController = [[BoardController alloc] initWithBoard:board];
	PhotoController *photoController = [[PhotoController alloc] initWithBoard:board];
	SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsView" bundle:nil board:board];
	
	// Order tabs going down from left to right
	UINavigationController *navController;
	
	navController = [[UINavigationController alloc] initWithRootViewController:boardController];
	navController.navigationBarHidden = YES;
	navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[controllers addObject:navController];
	[navController release];
	
	navController = [[UINavigationController alloc] initWithRootViewController:photoController];
	navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[controllers addObject:navController];
	[navController release];
	
	navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
	navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[controllers addObject:navController];
	[navController release];
		
	[boardController release];
	[photoController release];
	[settingsController release];
	
	UITabBarController *tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = controllers;
	tabBarController.delegate = board;
	
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	[controllers release];
	
	[board initialize];
	[board release];
}

- (void)dealloc
{
    [super dealloc];
}

@end
