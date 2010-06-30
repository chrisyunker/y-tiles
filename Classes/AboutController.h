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
	IBOutlet UIBarButtonItem *doneButton;
}

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)doneButtonAction;

@end
