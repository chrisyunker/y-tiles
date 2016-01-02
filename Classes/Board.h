//
//  Board.h
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
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
    CGSize size;
	GameState gameState;
	Configuration *config;
	NSMutableArray *tiles;
	Tile ***grid;
	UIImage *photo;
	Coord empty;
	NSLock *tileLock;
	SystemSoundID tockSSID;
	BoardController *boardController;
	UIImageView *pausedView;
	WaitImageView *waitImageView;
	NSMutableDictionary *boardState;
	BOOL boardSaved;
    AVAudioPlayer *player;
}

@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, readonly) Configuration *config;
@property (readonly) NSLock *tileLock;
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, retain) BoardController *boardController;
@property (nonatomic, readonly) CGSize size;

- (id)initWithSize:(CGSize)aSize;
- (void)createNewBoard;
- (void)restart;
- (void)start;
- (void)pause;
- (void)resume;
- (void)setPhoto:(UIImage *)aPhoto type:(int)aType;
- (void)cropPhoto:(UIImage *)image;
- (void)configChanged:(BOOL)restart;
- (void)moveTileFromCoordinate:(Coord)coord1 toCoordinate:(Coord)coord2;
- (void)updateGrid;
- (void)saveBoard;

@end
