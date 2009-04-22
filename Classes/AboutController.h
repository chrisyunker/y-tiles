//
//  AboutController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/18/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AboutController : UIViewController
{
	IBOutlet UILabel *versionLabel;
	IBOutlet UIButton *webButton;
	IBOutlet UIButton *emailButton;
	IBOutlet UIBarButtonItem *doneButton;
}

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIButton *webButton;
@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)webButtonAction;
- (IBAction)emailButtonAction;
- (IBAction)doneButtonAction;

@end
