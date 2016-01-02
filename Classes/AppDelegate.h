//
//  AppDelegate.h
//  Y-Tiles
//
//  Created by Chris Yunker on 12/31/15.
//
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import <UIKit/UIKit.h>
#import "Board.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSMutableArray *controllers;
@property (readonly, strong, nonatomic) Board *board;

@end

#endif /* AppDelegate_h */
