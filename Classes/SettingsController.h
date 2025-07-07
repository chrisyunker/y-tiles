//
//  SettingsController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 1/3/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "AboutController.h"
#import "Configuration.h"
#import "Constants.h"

#define COLUMN_INDEX     0
#define ROW_INDEX        1

@interface SettingsController : UIViewController <UIPickerViewDelegate>
{
	IBOutlet UIPickerView *pickerView;
	IBOutlet UISwitch *photoSwitch;
	IBOutlet UISwitch *numberSwitch;
	IBOutlet UISwitch *soundSwitch;
	IBOutlet UIButton *infoButton;
    IBOutlet UIButton *restartButton;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UINavigationBar *settingsNavigationBar;
	UIButton *customSaveButton;
	UIButton *customCancelButton;
	Board *board;
}

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UISwitch *photoSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *numberSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet UIButton *restartButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UINavigationBar *settingsNavigationBar;
@property (nonatomic, strong) UIButton *customSaveButton;
@property (nonatomic, strong) UIButton *customCancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard;
- (IBAction)saveButtonAction;
- (IBAction)cancelButtonAction;
- (IBAction)photoSwitchAction;
- (IBAction)numberSwitchAction;
- (IBAction)soundSwitchAction;
- (IBAction)infoButtonAction;

@end
