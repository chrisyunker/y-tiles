//
//  BoardController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/7/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import "BoardController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BoardController

@synthesize startButton;
@synthesize restartButton;
@synthesize resumeButton;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{		
		board = aBoard;
		[board setBoardController:self];
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"BoardTitle", @"")
                                                           image:[UIImage imageNamed:@"Board"]
                                                             tag:kTabBarBoardTag]];
    }
    return self;
}

- (void)dealloc
{
	DLog("dealloc");
}

- (void)didReceiveMemoryWarning
{
	ALog("didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setView:(UIView *)aView
{
	if (aView == nil)
	{
		DLog("Setting view to nil due to low memory");
		[self setStartButton:nil];
		[self setResumeButton:nil];
		[self setRestartButton:nil];
	}
	[super setView:aView];
}


- (void)loadView
{
    [super loadView];
	
	if (startButton == nil)
	{
		DLog("Create start button");

		// Create a custom button with semi-opaque background
		UIButton *customStartButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[customStartButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		// Set button size
		customStartButton.frame = CGRectMake(0, 0, 80, 32);
		
		// Use modern UIButtonConfiguration for iOS 15+
		UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
		config.title = NSLocalizedString(@"StartButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(6, 12, 6, 12);
		
		// Add semi-opaque background
		config.background.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
		config.background.cornerRadius = 8.0;
		
		customStartButton.configuration = config;
		
		startButton = [[UIBarButtonItem alloc] initWithCustomView:customStartButton];
	}
	
	if (restartButton == nil)
	{
		// Create a custom restart button with semi-opaque background
		UIButton *customRestartButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[customRestartButton addTarget:self action:@selector(restartButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		// Set button size
		customRestartButton.frame = CGRectMake(0, 0, 80, 32);
		
		// Use modern UIButtonConfiguration
		UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
		config.title = NSLocalizedString(@"RestartButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(6, 12, 6, 12);
		
		// Add semi-opaque background
		config.background.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
		config.background.cornerRadius = 8.0;
		
		customRestartButton.configuration = config;
		
		restartButton = [[UIBarButtonItem alloc] initWithCustomView:customRestartButton];
	}
	
	if (resumeButton == nil)
	{
		// Create a custom resume button with semi-opaque background
		UIButton *customResumeButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[customResumeButton addTarget:self action:@selector(resumeButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		// Set button size
		customResumeButton.frame = CGRectMake(0, 0, 80, 32);
		
		// Use modern UIButtonConfiguration
		UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
		config.title = NSLocalizedString(@"ResumeButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(6, 12, 6, 12);
		
		// Add semi-opaque background
		config.background.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
		config.background.cornerRadius = 8.0;
		
		customResumeButton.configuration = config;
		
		resumeButton = [[UIBarButtonItem alloc] initWithCustomView:customResumeButton];
	}
    
    [board createNewBoard];
	[[self view] addSubview:board];
}

- (void)startButtonAction
{
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	[board start];
}

- (void)restartButtonAction
{
	[[self navigationController] setNavigationBarHidden:YES animated:YES];	
	[board start];
}

- (void)resumeButtonAction
{
	[[self navigationController] setNavigationBarHidden:YES animated:YES];	
	[board resume];
}

- (void)displayRestartMenu
{
	//DLog("displayRestartMenu");
	
	[[self navigationItem] setLeftBarButtonItem:restartButton];
	[[self navigationItem] setRightBarButtonItem:resumeButton];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)displayStartMenu
{
	//DLog("displayStartMenu");
	
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)removeMenu
{
	[[self navigationController] setNavigationBarHidden:YES animated:NO];	
}

- (void)displaySolvedMenu
{
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
		
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TilesSolved", @"")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
