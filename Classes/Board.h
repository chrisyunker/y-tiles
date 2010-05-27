//
//  Board.h
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "Tile.h"
#import "Configuration.h"
#import "Constants.h"
#import "DataTypes.h"
#import "BoardController.h"
#import "WaitImageView.h"
#import "Util.h"

@class Tile;
@class BoardController;
@class Configuration;

@interface Board : UIView
{
	GameState gameState;
	Configuration *config;
	NSMutableArray *tiles;
	Tile ***grid;
	CGSize tileSize;
	UIImage *photo;
	Coordinate empty;
	NSLock *tileLock;
	SystemSoundID tockSSID;
	BoardController *boardController;
	UIImageView *pausedView;
	WaitImageView *waitImageView;
	NSMutableDictionary *boardState;
	BOOL boardSaved;
}

@property (retain) UIImage *photo;
@property (nonatomic, readonly) Configuration *config;
@property (nonatomic, readonly) NSLock *tileLock;
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, retain) BoardController *boardController;

- (void)initialize;
- (void)start;
- (void)restart;
- (void)pause;
- (void)resume;
- (void)setPhoto:(UIImage *)aPhoto type:(int)aType;
- (void)configChanged:(BOOL)restart;
- (void)moveTileFromCoordinate:(Coordinate)loc1 toCoordinate:(Coordinate)loc2;
- (void)updateGrid;
- (void)saveBoard;

@end
