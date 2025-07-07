//
//  AboutController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/18/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import "AboutController.h"

@implementation AboutController

@synthesize versionLabel;
@synthesize copyrightLabel;
@synthesize doneButton;
@synthesize icon;
@synthesize aboutNavigationBar;
@synthesize customDoneButton;

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

- (void)viewDidLoad 
{
	[super viewDidLoad];
		
	NSString *version = [NSString stringWithFormat:@"%@ %d.%d",
						 NSLocalizedString(@"VersionLabel", @""),
						 kVersionMajor,
						 kVersionMinor];
	[versionLabel setText:version];
    
    NSString *copyrightYear = [NSString stringWithFormat:@"%@ © %d",
                               NSLocalizedString(@"CopyrightLabel", @""),
                               kCopyrightYear];
    [copyrightLabel setText:copyrightYear];
	
	UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																  pathForResource:kIconPhoto
																  ofType:kIconPhotoType]];
	[icon setImage:iconImage];
	
	// Create modern Done button
	[self createModernDoneButton];
}

- (void)createModernDoneButton
{
	// Create Done button with same styling as Start button
	customDoneButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[customDoneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
	customDoneButton.frame = CGRectMake(0, 0, 80, 32);
	
	UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
	config.title = @"Done";
	config.baseForegroundColor = [UIColor whiteColor];
	config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
	config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
		NSMutableDictionary *attrs = [textAttributes mutableCopy];
		attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
		return attrs;
	};
	
	// Use the same blue color as the Start button
	config.background.backgroundColor = [UIColor systemBlueColor];
	config.background.cornerRadius = 10.0;
	
	customDoneButton.configuration = config;
	
	// Replace the XIB button with our custom one
	doneButton = [[UIBarButtonItem alloc] initWithCustomView:customDoneButton];
	
	// Update the navigation item from the embedded navigation bar
	UINavigationItem *navItem = [[aboutNavigationBar items] firstObject];
	[navItem setRightBarButtonItem:doneButton];
}

- (void)setView:(UIView *)aView
{
	if (aView == nil)
	{
		DLog("Setting view to nil due to low memory");
		[self setVersionLabel:nil];
        [self setCopyrightLabel:nil];
		[self setDoneButton:nil];
		[self setIcon:nil];
	}
	
    [super setView:aView];
}

- (IBAction)doneButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
