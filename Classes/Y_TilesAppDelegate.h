//
//  Y_TilesAppDelegate.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/23/09.
//  Copyright Chris Yunker 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"

@class Y_TilesViewController;

@interface Y_TilesAppDelegate : NSObject <UIApplicationDelegate>
{
	NSMutableArray *controllers;
	Board *board;
}

@end

