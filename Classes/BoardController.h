//
//  BoardController.h
//  Y-Tiles
//
//  Created by Chris Yunker on 1/7/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>
#include "Board.h"

@class Board;

@interface BoardController : UIViewController
{
	Board *board;
	UIBarButtonItem *startButton;
	UIBarButtonItem *restartButton;
	UIBarButtonItem *resumeButton;
}

@property (nonatomic, strong) UIBarButtonItem *startButton;
@property (nonatomic, strong) UIBarButtonItem *restartButton;
@property (nonatomic, strong) UIBarButtonItem *resumeButton;


- (id)initWithBoard:(Board *)aBoard;
- (void)startButtonAction;
- (void)restartButtonAction;
- (void)resumeButtonAction;
- (void)displayStartMenu;
- (void)displayRestartMenu;
- (void)displaySolvedMenu;
- (void)removeMenu;

@end
