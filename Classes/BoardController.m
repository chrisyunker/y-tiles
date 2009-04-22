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

		[self.tabBarItem initWithTitle:NSLocalizedString(@"PlayTitle", @"")
		 image:[UIImage imageNamed:@"Play.png"]
		 tag:kTabBarBoardTag];
    }
    return self;
}

- (void)dealloc
{
	DLog(@"dealloc");
	
	[startButton release];
	[restartButton release];
	[resumeButton release];
	[board release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)loadView
{
    [super loadView];
	
	board.boardController = self;
		
	self.startButton = [[[UIBarButtonItem alloc]
						initWithTitle:[NSString stringWithFormat:@"  %@  ", NSLocalizedString(@"StartButton", @"")]
						style:UIBarButtonItemStyleDone
						target:self
						action:@selector(startButtonAction)] autorelease];
		
	self.restartButton = [[[UIBarButtonItem alloc]
						  initWithTitle:NSLocalizedString(@"RestartButton", @"")
						  style:UIBarButtonItemStyleDone
						  target:self
						  action:@selector(restartButtonAction)] autorelease];
	
	self.resumeButton = [[[UIBarButtonItem alloc]
						 initWithTitle:NSLocalizedString(@"ResumeButton", @"")
						 style:UIBarButtonItemStyleDone
						 target:self
						 action:@selector(resumeButtonAction)] autorelease];
		
	[self.view addSubview:board];
}

- (void)startButtonAction
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[board start];
}

- (void)restartButtonAction
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];	
	[board start];
}

- (void)resumeButtonAction
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];	
	[board resume];
}

- (void)displayRestartMenu
{
	self.navigationItem.leftBarButtonItem = restartButton;
	self.navigationItem.rightBarButtonItem = resumeButton;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)displayStartMenu
{
	self.navigationItem.leftBarButtonItem = startButton;
	self.navigationItem.rightBarButtonItem = nil;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)displaySolvedMenu
{
	self.navigationItem.leftBarButtonItem = startButton;
	self.navigationItem.rightBarButtonItem = nil;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
		
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedString(@"TilesSolved", @"")
						  message:nil
						  delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

@end
