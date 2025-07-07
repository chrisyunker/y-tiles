/*
 *  DataTypes.h
 *  Y-Tiles
 *
 *  Created by Chris Yunker on 2/17/09.
 *  Copyright 2025 Chris Yunker. All rights reserved.
 *
 */


struct Coord
{
	int x;
	int y;
};
typedef struct Coord Coord;


typedef enum
{
	None	   = 0,
	Up	 	   = 1,
	Down	   = 2,
	Left	   = 3,
	Right	   = 4
} Direction;


typedef enum
{
	GameNotStarted  = 0,
	GamePaused      = 1,
	GameInProgress  = 2
} GameState;
