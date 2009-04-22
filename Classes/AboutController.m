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
@synthesize webButton;
@synthesize emailButton;
@synthesize doneButton;

- (void)dealloc
{
	[versionLabel release], versionLabel = nil;
	[webButton release], webButton = nil;
	[emailButton release], emailButton = nil;
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
	
	[webButton setTitle:NSLocalizedString(@"WebButton", @"") forState:UIControlStateNormal];
	[emailButton setTitle:NSLocalizedString(@"EmailButton", @"") forState:UIControlStateNormal];
	
	NSString *version = [NSString stringWithFormat:@"%@ %d.%d",
						 NSLocalizedString(@"VersionLabel", @""),
						 kVersionMajor,
						 kVersionMinor];
	[versionLabel setText:version];
}

- (void)setView:(UIView *)aView
{
	if (!aView)
	{
		self.versionLabel = nil;
		self.webButton = nil;
		self.emailButton = nil;
		self.doneButton = nil;
	}
	
    [super setView:aView];
}

- (IBAction)webButtonAction
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kWebUrl]];
}

- (IBAction)emailButtonAction
{	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kEmailUrl]];
}

- (IBAction)doneButtonAction
{
	[self dismissModalViewControllerAnimated:YES];	
}

@end
