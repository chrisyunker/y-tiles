//
//  SettingsController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/3/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "SettingsController.h"

@implementation SettingsController

@synthesize pickerView;
@synthesize photoSwitch;
@synthesize numberSwitch;
@synthesize soundSwitch;
@synthesize infoButton;
@synthesize saveButton;
@synthesize cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		
		board = [aBoard retain];
		
		[self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SettingsTitle", @"")
														   image:[UIImage imageNamed:@"Settings.png"]
															 tag:kTabBarSettingsTag] autorelease]];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
	[pickerView release], pickerView = nil;
	[photoSwitch release], photoSwitch = nil;
	[numberSwitch release], numberSwitch = nil;
	[soundSwitch release], soundSwitch = nil;
	[infoButton release], infoButton = nil;
	[saveButton release];
	[cancelButton release];
	[board release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog("didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
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
	if (value)
	{
		[saveButton setStyle:UIBarButtonItemStyleDone];
		[cancelButton setStyle:UIBarButtonItemStyleDone];
	}
	else
	{
		[saveButton setStyle:UIBarButtonItemStylePlain];
		[cancelButton setStyle:UIBarButtonItemStylePlain];
	}
	
	[saveButton setEnabled:value];
	[cancelButton setEnabled:value];
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
}

- (void)viewDidLoad 
{	
    [super viewDidLoad];
	
	[self setSaveButton:[[[UIBarButtonItem alloc]
						  initWithTitle:NSLocalizedString(@"SaveSettingsButton", @"")
						  style:UIBarButtonItemStylePlain
						  target:self
						  action:@selector(saveButtonAction)] autorelease]];
	
	[self setCancelButton:[[[UIBarButtonItem alloc]
							initWithTitle:NSLocalizedString(@"CancelSettingsButton", @"")
							style:UIBarButtonItemStylePlain
							target:self
							action:@selector(cancelButtonAction)] autorelease]];
		
	[[self navigationItem] setLeftBarButtonItem:cancelButton];
	[[self navigationItem] setRightBarButtonItem:saveButton];
	[self enableButtons:NO];
}

- (void)saveButtonAction
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

- (void)cancelButtonAction
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
	[ac release];
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
