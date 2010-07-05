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
@synthesize icon;

- (void)dealloc
{
	DLog(@"dealloc");

	[versionLabel release], versionLabel = nil;
	[doneButton release], doneButton = nil;
	[icon release], icon = nil;
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
	
	UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																  pathForResource:kIconPhoto
																  ofType:kIconPhotoType]];
	[icon setImage:iconImage];
	[iconImage release];
}

- (void)setView:(UIView *)aView
{
	if (aView == nil)
	{
		DLog(@"Setting view to nil due to low memory");

		[self setVersionLabel:nil];
		[self setDoneButton:nil];
		[self setIcon:nil];
	}
	
    [super setView:aView];
}

- (IBAction)doneButtonAction
{
	[self dismissModalViewControllerAnimated:YES];	
}

@end
