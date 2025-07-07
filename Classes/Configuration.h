//
//  Configuration.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/16/09.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Board.h"

@class Board;

@interface Configuration : NSObject
{
	int columns;
	int rows;
	int photoType;
	BOOL photoEnabled;
	BOOL numbersEnabled;
	BOOL soundEnabled;
	Board *board;
}

@property (nonatomic, assign) int columns;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int photoType;
@property (nonatomic, assign) BOOL photoEnabled;
@property (nonatomic, assign) BOOL numbersEnabled;
@property (nonatomic, assign) BOOL soundEnabled;

- (id)initWithBoard:(Board *)aBoard;
- (void)load;
- (void)save;

@end
