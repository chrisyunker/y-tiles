//
//  PhotoController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "PhotoDefaultController.h"

@class Board;

@interface PhotoController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UIBarButtonItem *photoLibraryButton;
	UIBarButtonItem *photoDefaultButton;
	UIImageView *selectImageView;
	Board *board;
}

@property (nonatomic, strong) UIBarButtonItem *photoLibraryButton;
@property (nonatomic, strong) UIBarButtonItem *photoDefaultButton;
@property (nonatomic, strong) UIImageView *selectImageView;

- (id)initWithBoard:(Board *)aBoard;
- (void)photoLibraryButtonAction;
- (void)photoDefaultButtonAction;
- (void)selectPhoto:(UIImage *)photo type:(int)type;

@end