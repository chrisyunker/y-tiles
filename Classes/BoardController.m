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
        // Use SF Symbol for modern appearance
        UIImage *boardImage = [UIImage systemImageNamed:@"square.grid.3x3"];
        if (!boardImage) {
            // Fallback to original image if SF Symbols not available
            boardImage = [UIImage imageNamed:@"Board"];
        }
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"BoardTitle", @"")
                                                           image:boardImage
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
		
		// Use modern UIButtonConfiguration with improved styling
		UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
		config.title = NSLocalizedString(@"StartButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
		config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
			NSMutableDictionary *attrs = [textAttributes mutableCopy];
			attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
			return attrs;
		};
		
		// Modern gradient background with subtle shadow
		config.background.backgroundColor = [UIColor systemBlueColor];
		config.background.cornerRadius = 10.0;
		
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
		
		// Use modern UIButtonConfiguration with secondary styling
		UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
		config.title = NSLocalizedString(@"RestartButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
		config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
			NSMutableDictionary *attrs = [textAttributes mutableCopy];
			attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
			return attrs;
		};
		
		// Secondary button styling with orange accent
		config.background.backgroundColor = [UIColor systemBlueColor];
		config.background.cornerRadius = 10.0;
		
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
		
		// Use modern UIButtonConfiguration with accent styling
		UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
		config.title = NSLocalizedString(@"ResumeButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
		config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
			NSMutableDictionary *attrs = [textAttributes mutableCopy];
			attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
			return attrs;
		};
		
		// Accent button styling with green color for resume action
		config.background.backgroundColor = [UIColor systemBlueColor];
		config.background.cornerRadius = 10.0;
		
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
    [[self navigationItem] setLeftBarButtonItem:resumeButton];
	[[self navigationItem] setRightBarButtonItem:restartButton];
	
	// Add smooth animation with spring effect
	[UIView animateWithDuration:0.4
						  delay:0.0
		 usingSpringWithDamping:0.8
		  initialSpringVelocity:0.2
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [[self navigationController] setNavigationBarHidden:NO animated:NO];
					 }
					 completion:nil];
}

- (void)displayStartMenu
{
	//DLog("displayStartMenu");
	
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	
	// Add smooth animation with spring effect
	[UIView animateWithDuration:0.4
						  delay:0.0
		 usingSpringWithDamping:0.8
		  initialSpringVelocity:0.2
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [[self navigationController] setNavigationBarHidden:NO animated:NO];
					 }
					 completion:nil];
}

- (void)removeMenu
{
	[[self navigationController] setNavigationBarHidden:YES animated:NO];	
}

- (void)displaySolvedMenu
{
	[[self navigationItem] setLeftBarButtonItem:startButton];
	[[self navigationItem] setRightBarButtonItem:nil];
	
	// Add smooth animation with spring effect
	[UIView animateWithDuration:0.4
						  delay:0.0
		 usingSpringWithDamping:0.8
		  initialSpringVelocity:0.2
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [[self navigationController] setNavigationBarHidden:NO animated:NO];
					 }
					 completion:^(BOOL finished) {
						 // Celebratory haptic feedback and alert with delay for better UX
						 AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
						 
						 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
							 UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TilesSolved", @"")
																							message:nil
																					 preferredStyle:UIAlertControllerStyleAlert];
							 UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																					 style:UIAlertActionStyleDefault
																				   handler:^(UIAlertAction * action) {}];
							 [alert addAction:defaultAction];
							 [self presentViewController:alert animated:YES completion:nil];
						 });
					 }];
}

@end
