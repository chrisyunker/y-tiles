//
//  SettingsController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/3/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import "SettingsController.h"

@implementation SettingsController

@synthesize pickerView;
@synthesize photoSwitch;
@synthesize numberSwitch;
@synthesize soundSwitch;
@synthesize infoButton;
@synthesize restartButton;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize settingsNavigationBar;
@synthesize customSaveButton;
@synthesize customCancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		
		board = aBoard;
		// Use SF Symbol for modern appearance
		UIImage *settingsImage = [UIImage systemImageNamed:@"gearshape"];
		if (!settingsImage) {
			// Fallback to original image if SF Symbols not available
			settingsImage = [UIImage imageNamed:@"Settings"];
		}
		[self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SettingsTitle", @"")
														   image:settingsImage
															 tag:kTabBarSettingsTag]];
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
		[self setPickerView:nil];
		[self setPhotoSwitch:nil];
		[self setNumberSwitch:nil];
		[self setSoundSwitch:nil];
		[self setInfoButton:nil];
	}
	
    [super setView:aView];
}

- (void)updateControlsWithAnimation:(BOOL)animated
{
	[pickerView selectRow:(board.config.columns - kColumnsMin) inComponent:COLUMN_INDEX animated:animated];
	[pickerView selectRow:(board.config.rows - kRowsMin) inComponent:ROW_INDEX animated:animated];
	[photoSwitch setOn:board.config.photoEnabled animated:animated];
	[numberSwitch setOn:board.config.numbersEnabled animated:animated];
	[soundSwitch setOn:board.config.soundEnabled animated:animated];
}

- (void)enableButtons:(BOOL)value
{
	[customSaveButton setEnabled:value];
	[customCancelButton setEnabled:value];
	
	// Update button appearance based on enabled state
	if (value) {
		// Enabled state - full color
		UIButtonConfiguration *saveConfig = customSaveButton.configuration;
		saveConfig.background.backgroundColor = [UIColor systemBlueColor];
		saveConfig.baseForegroundColor = [UIColor whiteColor];
		customSaveButton.configuration = saveConfig;
		
		UIButtonConfiguration *cancelConfig = customCancelButton.configuration;
		cancelConfig.background.backgroundColor = [UIColor systemBlueColor];
		cancelConfig.baseForegroundColor = [UIColor whiteColor];
		customCancelButton.configuration = cancelConfig;
	} else {
		// Disabled state - grey out completely
		UIButtonConfiguration *saveConfig = customSaveButton.configuration;
		saveConfig.background.backgroundColor = [UIColor systemGrayColor];
		saveConfig.baseForegroundColor = [UIColor lightGrayColor];
		customSaveButton.configuration = saveConfig;
		
		UIButtonConfiguration *cancelConfig = customCancelButton.configuration;
		cancelConfig.background.backgroundColor = [UIColor systemGrayColor];
		cancelConfig.baseForegroundColor = [UIColor lightGrayColor];
		customCancelButton.configuration = cancelConfig;
	}
}

- (void)setEnabled:(BOOL)value
{
	[photoSwitch setEnabled:value];
	[numberSwitch setEnabled:value];
	[soundSwitch setEnabled:value];
	[infoButton setEnabled:value];
	
	if (value)
	{		
		[self updateControlsWithAnimation:YES];
		[self enableButtons:NO];
	}
	else
	{
		[self enableButtons:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	[self updateControlsWithAnimation:NO];
	[self enableButtons:NO];
	
	// Ensure tab bar is properly configured and visible
	[[[self tabBarController] tabBar] setHidden:NO];
	[[[self tabBarController] tabBar] setUserInteractionEnabled:YES];
	[[[self tabBarController] tabBar] setAlpha:1.0];
}

- (void)viewDidLoad 
{	
    [super viewDidLoad];
	[self enableButtons:NO];
	
	// Remove the navigation title
	self.title = nil;
	self.navigationItem.title = nil;
	
	// Create consistent modern buttons
	[self createModernButtons];
	
	// Style the restart button
	[self styleRestartButton];
}

- (void)createModernButtons
{
	// Create Cancel button with consistent styling
	customCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[customCancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
	customCancelButton.frame = CGRectMake(0, 0, 80, 32);
	
	UIButtonConfiguration *cancelConfig = [UIButtonConfiguration filledButtonConfiguration];
	cancelConfig.title = @"Cancel";
	cancelConfig.baseForegroundColor = [UIColor whiteColor];
	cancelConfig.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
	cancelConfig.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
		NSMutableDictionary *attrs = [textAttributes mutableCopy];
		attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
		return attrs;
	};
	cancelConfig.background.backgroundColor = [UIColor systemBlueColor];
	cancelConfig.background.cornerRadius = 10.0;
	customCancelButton.configuration = cancelConfig;
	
	// Create Save button with consistent styling
	customSaveButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[customSaveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
	customSaveButton.frame = CGRectMake(0, 0, 80, 32);
	
	UIButtonConfiguration *saveConfig = [UIButtonConfiguration filledButtonConfiguration];
	saveConfig.title = @"Save";
	saveConfig.baseForegroundColor = [UIColor whiteColor];
	saveConfig.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
	saveConfig.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
		NSMutableDictionary *attrs = [textAttributes mutableCopy];
		attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
		return attrs;
	};
	saveConfig.background.backgroundColor = [UIColor systemBlueColor];
	saveConfig.background.cornerRadius = 10.0;
	customSaveButton.configuration = saveConfig;
	
	// Replace the XIB buttons with our custom ones
	cancelButton = [[UIBarButtonItem alloc] initWithCustomView:customCancelButton];
	saveButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
	
	// Update the navigation item from the embedded navigation bar
	UINavigationItem *navItem = [[settingsNavigationBar items] firstObject];
	[navItem setLeftBarButtonItem:cancelButton];
	[navItem setRightBarButtonItem:saveButton];
}

- (void)styleRestartButton
{
	// Apply modern styling to the restart button to match the Start button
	UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
	config.title = @"Restart Game";
	config.baseForegroundColor = [UIColor whiteColor];
	config.contentInsets = NSDirectionalEdgeInsetsMake(12, 24, 12, 24);
	config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
		NSMutableDictionary *attrs = [textAttributes mutableCopy];
		attrs[NSFontAttributeName] = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
		return attrs;
	};
	
	// Use the same blue color as the Start button
	config.background.backgroundColor = [UIColor systemBlueColor];
	config.background.cornerRadius = 12.0;
	
	restartButton.configuration = config;
}

- (IBAction)saveButtonAction
{
	// Save configuration values
    [[board config] setColumns:((int)[pickerView selectedRowInComponent:COLUMN_INDEX] + kColumnsMin)];
    [[board config] setRows:((int)[pickerView selectedRowInComponent:ROW_INDEX] + kRowsMin)];
	[[board config] setPhotoEnabled:[photoSwitch isOn]];
	[[board config] setNumbersEnabled:[numberSwitch isOn]];
	[[board config] setSoundEnabled:[soundSwitch isOn]];
	[[board config] save];
			
	[self enableButtons:NO];
}

- (IBAction)cancelButtonAction
{		
	[self updateControlsWithAnimation:YES];
	[self enableButtons:NO];
}

- (IBAction)photoSwitchAction
{	
	[self enableButtons:YES];
}

- (IBAction)numberSwitchAction
{	
	[self enableButtons:YES];
}

- (IBAction)soundSwitchAction
{	
	[self enableButtons:YES];
}

- (IBAction)infoButtonAction
{
	AboutController *ac = [[AboutController alloc] initWithNibName:@"AboutView" bundle:nil];
    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)restartAction
{
    [board restart];
}


#pragma mark UIPickerViewDelegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pView numberOfRowsInComponent:(NSInteger)component
{
	switch(component)
	{
		case(COLUMN_INDEX):
			return (kColumnsMax - kColumnsMin + 1);
			break;
		case(ROW_INDEX):
			return (kRowsMax - kRowsMin + 1);
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch(component)
	{
		case(COLUMN_INDEX):
            return [NSString stringWithFormat:@"%d %@", ((int)row + kRowsMin), NSLocalizedString(@"ColumnsLabel", @"")];
			break;
		case(ROW_INDEX):
            return [NSString stringWithFormat:@"%d %@", ((int)row + kRowsMin), NSLocalizedString(@"RowsLabel", @"")];
			break;
		default:
			return [NSString stringWithFormat:@"Error"];
			break;
	}
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[self enableButtons:YES];
}

@end
