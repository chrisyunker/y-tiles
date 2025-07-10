//
//  AboutController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/18/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AboutController : UIViewController
{
	IBOutlet UILabel *versionLabel;
    IBOutlet UILabel *copyrightLabel;
	IBOutlet UIBarButtonItem *doneButton;
	IBOutlet UIImageView *icon;
	IBOutlet UINavigationBar *aboutNavigationBar;
	UIButton *customDoneButton;
}

@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UILabel *copyrightLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIImageView *icon;
@property (nonatomic, strong) IBOutlet UINavigationBar *aboutNavigationBar;
@property (nonatomic, strong) UIButton *customDoneButton;

- (IBAction)doneButtonAction;

@end
