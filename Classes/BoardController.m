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

		[self.tabBarItem initWithTitle:NSLocalizedString(@"BoardTitle", @"")
		 image:[UIImage imageNamed:@"Board.png"]
		 tag:kTabBarBoardTag];
		
		accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
		accelerometer.delegate = self;
		accelerometer.updateInterval = kUpdateInterval;
		shakeCount = 0;
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
	[accelerometer release];
	[lastAcceleration release];
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


#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	selectedViewController = viewController.tabBarController.selectedIndex;
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
