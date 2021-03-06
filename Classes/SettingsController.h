//
//  SettingsController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 1/3/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
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
	Board *board;
}

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UISwitch *photoSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *numberSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIButton *restartButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard;
- (IBAction)saveButtonAction;
- (IBAction)cancelButtonAction;
- (IBAction)photoSwitchAction;
- (IBAction)numberSwitchAction;
- (IBAction)soundSwitchAction;
- (IBAction)infoButtonAction;

@end
