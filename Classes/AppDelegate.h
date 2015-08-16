//
//  Y_TilesAppDelegate.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/23/09.
//  Copyright Chris Yunker 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSMutableArray *controllers;
@property (readonly, strong, nonatomic) Board *board;

@end

