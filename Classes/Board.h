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

@interface Board : UIView <UITabBarControllerDelegate, UIAccelerometerDelegate>
{
	Configuration *config;
	UIImageView *pausedView;
	WaitImageView *waitImageView;
	CGSize tileSize;
	UIImage *photo;
	NSMutableArray *boardTiles;
	Tile ***grid;
	Coordinate empty;
	NSLock *tileLock;
	SystemSoundID tockSSID;
	BoardController *boardController;
	int selectedViewController;
	GameState gameState;
	CGMutablePathRef tilePhotoBorderPath;
	CGMutablePathRef tileNumberBorderPath;
	CFMutableDictionaryRef numberBorderPaths;
	UIAccelerometer *accelerometer;
	UIAcceleration *lastAcceleration;
	int shakeCount;	
}

@property (retain) UIImage *photo;
@property (nonatomic, readonly) Configuration *config;
@property (nonatomic, readonly) NSLock *tileLock;
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, retain) BoardController *boardController;
@property (nonatomic, retain) UIAcceleration *lastAcceleration;

- (void)initialize;
- (void)start;
- (void)restart;
- (void)pause;
- (void)resume;
- (void)setPhoto:(UIImage *)aPhoto type:(int)aType;
- (void)setConfiguration:(Configuration *)aConfiguration;
- (void)moveTileFromCoordinate:(Coordinate)loc1 toCoordinate:(Coordinate)loc2;
- (void)updateGrid;
- (CGMutablePathRef)getTilePhotoBorderPath;
- (CGMutablePathRef)getTileNumberBorderPath;
- (CGMutablePathRef)getNumberBorderPathForTextWidth:(float)textWidth;

@end
