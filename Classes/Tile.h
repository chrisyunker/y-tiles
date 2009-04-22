//
//  Tile.h
//  Y-Tiles
//
//  Created by Chris Yunker on 1/11/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Board.h"
#import "Configuration.h"
#import "DataTypes.h"
#import "Util.h"

@class Board;

@interface Tile : UIImageView
{
	Coordinate home;
	Coordinate loc;
	int tileId;
	int tileWidth;
	int tileHeight;
	CGRect tileFrame;
	UIImage *photoImage;
	UIImage *numberedPhotoImage;
	UIImage *numberImage;
	CGPoint point;
	MoveType moveType;
	Tile *pushTile;
	Board *board;
	CGPoint startLocation;
	BOOL solved;
	BOOL haveLock;
}

@property (nonatomic, readonly) int tileId;
@property (nonatomic, readonly) BOOL solved;
@property (nonatomic, readwrite) MoveType moveType;
@property (nonatomic, assign) Tile *pushTile;
@property (nonatomic, readonly) Board *board;

- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId loc:(Coordinate)aLoc photo:(UIImage *)aPhoto;
- (void)drawTile;
- (void)moveToCoordinate:(Coordinate)aLoc;
- (void)moveToHomeCoordinate;
- (void)moveInDirection:(MoveType)type;
- (void)slideTileInDirection:(MoveType)type distance:(CGFloat)distance;

@end
