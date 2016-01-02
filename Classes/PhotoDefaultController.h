//
//  PhotoDefaultController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/26/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoController.h"
#import "Constants.h"

@class PhotoController;

@interface PhotoDefaultController : UIViewController
{
    PhotoController *photoController;
    UIButton *defaultPhoto1;
    UIButton *defaultPhoto2;
    UIButton *defaultPhoto3;
    UIButton *defaultPhoto4;
    UIBarButtonItem *cancelButton;
    UINavigationBar *navBar;
}

@property (nonatomic, retain)  UIButton *defaultPhoto1;
@property (nonatomic, retain)  UIButton *defaultPhoto2;
@property (nonatomic, retain)  UIButton *defaultPhoto3;
@property (nonatomic, retain)  UIButton *defaultPhoto4;
@property (nonatomic, retain)  UIBarButtonItem *cancelButton;
@property (nonatomic, retain)  UINavigationBar *navBar;

- (id)initWithPhotoController:(PhotoController *)aPhotoController;
- (void)selectPhoto1Action;
- (void)selectPhoto2Action;
- (void)selectPhoto3Action;
- (void)selectPhoto4Action;
- (void)cancelButtonAction;

@end
