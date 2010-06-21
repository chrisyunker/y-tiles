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
@synthesize lastAcceleration;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{		
		board = [aBoard retain];
		[board setBoardController:self];
		
		[[self tabBarItem] initWithTitle:NSLocalizedString(@"BoardTitle", @"")
								   image:[UIImage imageNamed:@"Board.png"]
									 tag:kTabBarBoardTag];
		
		shakeCount = 0;
		accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
		[accelerometer setDelegate:self];
		[accelerometer setUpdateInterval:kUpdateInterval];
    }
    return self;
}

- (void)dealloc
{
	DLog(@"dealloc");
	
	[board release];
	[startButton release];
	[restartButton release];
	[resumeButton release];
	[accelerometer release];
	[lastAcceleration release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)setView:(UIView *)aView
{
	DLog(@"setView [%@]", aView);
	if (aView == nil)
	{
		DLog(@"aView is nil");
		
	}
	[super setView:aView];
}


- (void)loadView
{
    [super loadView];
	DLog(@"loadView");
	
	if (startButton == nil)
	{
		DLog(@"create start button");

		startButton = [[UIBarButtonItem alloc]
					   initWithTitle:[NSString stringWithFormat:@"  %@  ", NSLocalizedString(@"StartButton", @"")]
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

	
	[[self view] addSubview:board];
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");	
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	DLog(@"viewDidDisappear");
	[super viewDidDisappear:animated];
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
	DLog(@"displayRestartMenu");
	
	[[self navigationItem] setLeftBarButtonItem:restartButton];
	[[self navigationItem] setRightBarButtonItem:resumeButton];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)displayStartMenu
{
	DLog(@"displayStartMenu");
	
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)displaySolvedMenu
{
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
		
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


#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	selectedViewController = [[viewController tabBarController] selectedIndex];
}

#pragma mark UIAccelerometerDelegate methods

- (BOOL)thresholdShakeLast:(UIAcceleration *)last current:(UIAcceleration *)current threshold:(double)threshold
{
	double diffX = fabs(last.x - current.x);
	double diffY = fabs(last.y - current.y);
	double diffZ = fabs(last.z - current.z);
	
	if ((diffX > threshold) && (diffY > threshold) ||
		(diffY > threshold) && (diffZ > threshold) ||
		(diffZ > threshold) && (diffX > threshold))
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if (self.lastAcceleration)
	{
		if ([self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdHigh] &&
			shakeCount > kShakeCount)
		{
			if (selectedViewController == kBoardControllerIndex)
			{
				if (board.gameState == GameInProgress)
				{
					board.gameState = GamePaused;
					[self displayRestartMenu];
				}
			}
			
			shakeCount = 0;
        }
		else if ([self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdHigh])
		{
			shakeCount += 1;
        }
		else if (![self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdLow])
		{
			if (shakeCount > 0)
			{
				shakeCount -= 1;
			}
        }
	}
	
	self.lastAcceleration = acceleration;
}

@end
