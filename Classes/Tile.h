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
#import "DataTypes.h"
#import "Util.h"

@class Board;

@interface Tile : UIImageView
{
	int tileId;
	CGPoint startOrigin;
	CGPoint startPoint;
	Coord coord;
	Coord homeCoord;
	UIImage *photoImage;
	UIImage *numberedPhotoImage;
	UIImage *numberImage;
	Direction moveType;
	Tile *pushTile;
	BOOL solved;
	BOOL haveLock;
	Board *board;
}

@property (nonatomic, readonly) int tileId;
@property (nonatomic, readonly) BOOL solved;
@property (nonatomic, readwrite) Direction moveType;
@property (nonatomic, assign) Tile *pushTile;

+ (Tile *)tileWithId:(int)aId board:(Board *)aBoard coord:(Coord)aCoord photo:(UIImage *)aPhoto;
- (void)drawTile;
- (void)moveToCoord:(Coord)coord;
- (void)moveToCoordX:(int)x coordY:(int)y;
- (void)moveInDirection:(Direction)type;
- (void)slideInDirection:(Direction)direction distance:(CGFloat)distance;

@end
