//
//  AboutController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/18/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "AboutController.h"

@implementation AboutController

@synthesize versionLabel;
@synthesize doneButton;

- (void)dealloc
{
	DLog(@"dealloc");

	[versionLabel release], versionLabel = nil;
	[doneButton release], doneButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
		
	NSString *version = [NSString stringWithFormat:@"%@ %d.%d",
						 NSLocalizedString(@"VersionLabel", @""),
						 kVersionMajor,
						 kVersionMinor];
	[versionLabel setText:version];
}

- (void)setView:(UIView *)aView
{
	if (aView == nil)
	{
		DLog(@"Setting view to nil due to low memory");

		self.versionLabel = nil;
		self.doneButton = nil;
	}
	
    [super setView:aView];
}

- (IBAction)doneButtonAction
{
	[self dismissModalViewControllerAnimated:YES];	
}

@end
