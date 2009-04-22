/*
 *  DataTypes.h
 *  Y-Tiles
 *
 *  Created by Chris Yunker on 2/17/09.
 *  Copyright 2009 Chris Yunker. All rights reserved.
 *
 */

struct Coordinate
{
	int x;
	int y;
};
typedef struct Coordinate Coordinate;

typedef enum
{
	MoveNone	   = 0,
	MoveUp	 	   = 1,
	MoveDown	   = 2,
	MoveLeft	   = 3,
	MoveRight	   = 4,
} MoveType;

typedef enum
{
	GamePaused      = 0,
	GameInProgress  = 1,
} GameState;
