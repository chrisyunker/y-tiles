//
//  PhotoController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "PhotoDefaultController.h"

@class Board;

@interface PhotoController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
	UIBarButtonItem *photoPickerButton;
	UIBarButtonItem *photoDefaultButton;
	Board *board;
	UIImageView *selectImageView;
}

@property (nonatomic, retain) UIBarButtonItem *photoPickerButton;
@property (nonatomic, retain) UIBarButtonItem *photoDefaultButton;

- (id)initWithBoard:(Board *)aBoard;
- (void)photoPickerButtonAction;
- (void)photoDefaultButtonAction;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
