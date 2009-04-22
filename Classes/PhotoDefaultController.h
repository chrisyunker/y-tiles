//
//  PhotoDefaultController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/26/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "Constants.h"

@interface PhotoDefaultController : UIViewController
{
	Board *board;
	IBOutlet UIButton *defaultPhoto1;
	IBOutlet UIButton *defaultPhoto2;
	IBOutlet UIButton *defaultPhoto3;
	IBOutlet UIButton *defaultPhoto4;
	IBOutlet UIBarButtonItem *cancelButton;
}

@property (nonatomic, retain) IBOutlet UIButton *defaultPhoto1;
@property (nonatomic, retain) IBOutlet UIButton *defaultPhoto2;
@property (nonatomic, retain) IBOutlet UIButton *defaultPhoto3;
@property (nonatomic, retain) IBOutlet UIButton *defaultPhoto4;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard;
- (IBAction)selectPhoto1Action;
- (IBAction)selectPhoto2Action;
- (IBAction)selectPhoto3Action;
- (IBAction)selectPhoto4Action;
- (IBAction)cancelButtonAction;

@end
