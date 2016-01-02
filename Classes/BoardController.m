//
//  BoardController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/7/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "BoardController.h"

@implementation BoardController

@synthesize startButton;
@synthesize restartButton;
@synthesize resumeButton;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{		
		board = [aBoard retain];
		[board setBoardController:self];
        [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"BoardTitle", @"")
                                                           image:[UIImage imageNamed:@"Board"]
                                                             tag:kTabBarBoardTag] autorelease]];
    }
    return self;
}

- (void)dealloc
{
	DLog("dealloc");
	[board release];
	[startButton release], startButton = nil;
	[restartButton release], restartButton = nil;
	[resumeButton release], resumeButton = nil;
    [super dealloc];
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

		startButton = [[UIBarButtonItem alloc]
					   initWithTitle:NSLocalizedString(@"StartButton", @"")
					   style:UIBarButtonItemStyleDone
					   target:self
					   action:@selector(startButtonAction)];
	}
	
	if (restartButton == nil)
	{
		restartButton = [[UIBarButtonItem alloc]
						 initWithTitle:NSLocalizedString(@"RestartButton", @"")
						 style:UIBarButtonItemStyleDone
						 target:self
						 action:@selector(restartButtonAction)];
	}
	
	if (resumeButton == nil)
	{
		resumeButton = [[UIBarButtonItem alloc]
						initWithTitle:NSLocalizedString(@"ResumeButton", @"")
						style:UIBarButtonItemStyleDone
						target:self
						action:@selector(resumeButtonAction)];
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
