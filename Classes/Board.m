//
//  Board.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Board.h"
#import "BoardCoordinate.h"

@interface Board (Private)

- (void)createTilesForBoard;
- (void)scrambleBoard;
- (void)showWaitView;
- (void)removeWaitView;
- (void)createTilesForBoardInThread;
- (void)drawBoard;
- (void)restoreBoard;

@end


@implementation Board

@synthesize photo;
@synthesize config;
@synthesize tileLock;
@synthesize gameState;
@synthesize boardController;

- (id)init
{
	if (self = [super initWithFrame:CGRectMake(kBoardX, kBoardY, kBoardWidth, kBoardHeight)])
	{
		config = [[Configuration alloc] init];
		config.board = self;
		[config load];
		
		[self restoreBoard];
		
		gameState = GameNotStarted;

		tileSize = CGSizeMake(trunc(self.frame.size.width / config.columns),
							  trunc(self.frame.size.height / config.rows));
		
						
		// Create grid to handle largest possible configuration
		grid = malloc(kColumnsMax * sizeof(Tile **));
		if (grid == NULL)
		{
			ALog(@"Board:init Memory allocation error");
			return nil;
		}
		for (int x = 0; x < kColumnsMax; x++)
		{
			grid[x] = malloc(kRowsMax * sizeof(Tile *));
			if (grid[x] == NULL)
			{
				ALog(@"Board:init Memory allocation error");
				return nil;
			}
		}
		
		tileLock = [[NSLock alloc] init];
		
		switch (config.photoType)
		{
			case kDefaultPhoto1Type:
				self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																	   pathForResource:kDefaultPhoto1
																	   ofType:kPhotoType]] autorelease];
				break;
			case kDefaultPhoto2Type:
				self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																	   pathForResource:kDefaultPhoto2
																	   ofType:kPhotoType]] autorelease];
				break;
			case kDefaultPhoto3Type:
				self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																	   pathForResource:kDefaultPhoto3
																	   ofType:kPhotoType]] autorelease];
				break;
			case kDefaultPhoto4Type:
				self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																	   pathForResource:kDefaultPhoto4
																	   ofType:kPhotoType]] autorelease];
				break;
			case kBoardPhotoType:
				self.photo = [UIImage imageWithContentsOfFile:[kDocumentsDir stringByAppendingPathComponent:kBoardPhoto]];
				if (self.photo == nil)
				{
					ALog(@"Board:init Failed to load last board image [%@]",
						  [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto]);
					
					self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																		   pathForResource:kDefaultPhoto1
																		   ofType:kPhotoType]] autorelease];
				}
				break;
			default:
				self.photo = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																	   pathForResource:kDefaultPhoto1
																	   ofType:kPhotoType]] autorelease];
		}
		
		waitImageView = [[WaitImageView alloc] init];
		pausedView = [Util createPausedViewWithFrame:self.frame];
		[self addSubview:pausedView];

		NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
		NSURL *url = [NSURL fileURLWithPath:[uiKitBundle pathForResource:kTileSoundName ofType:kTileSoundType]];
		OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef) url, &tockSSID);
		if (error) ALog(@"Board:init Failed to create sound for URL [%@]", url);
		
		self.backgroundColor = [UIColor blackColor];
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = NO;
	}
	
    return self;
}

- (void)dealloc
{
	// Free 2D grid array
	for (int i = 0; i < kColumnsMax; i++)
	{
		if (grid[i]) free(grid[i]);
	}
	if (grid) free(grid);
		
	AudioServicesDisposeSystemSoundID(tockSSID);
	[config release];
	[pausedView release];
	[waitImageView release];
	[photo release];
	[tiles release];
	[tileLock release];
	[boardController release];
	[super dealloc];
}

- (void)initialize
{		
	[self showWaitView];
	[NSThread detachNewThreadSelector:@selector(createTilesForBoardInThread)
							 toTarget:self
						   withObject:nil];
}

- (void)start
{
	[self scrambleBoard];
	self.gameState = GameInProgress;
}

- (void)restart
{	
	[self scrambleBoard];
	self.gameState = GameInProgress;
}

- (void)pause
{
	self.gameState = GamePaused;
}

- (void)resume
{
	self.gameState = GameInProgress;
}

- (void)setGameState:(GameState)state
{
	DLog("Old State [%d] New State [%d]", gameState, state);
	
	gameState = state;
	
	switch (gameState)
	{
		case GameNotStarted:
		case GamePaused:
			self.userInteractionEnabled = NO;
			pausedView.alpha = 1.0f;
			[self bringSubviewToFront:pausedView];
			
			break;
		case GameInProgress:
			self.userInteractionEnabled = YES;
			pausedView.alpha = 0.0f;

			break;
		default:
			break;
	}
}

- (void)configChanged:(BOOL)restart
{
	if (restart)
	{
		self.gameState = GameNotStarted;
		[self showWaitView];
		[NSThread detachNewThreadSelector:@selector(createTilesForBoardInThread) toTarget:self withObject:nil];
	}
	else	
	{
		[self drawBoard];		
	}
}

- (void)setPhoto:(UIImage *)aPhoto type:(int)aType
{
	self.gameState = GameNotStarted;

	self.photo = aPhoto;
	
	config.photoType = aType;
	config.photoEnabled = YES;
	[config save];
	
	[self showWaitView];
	[NSThread detachNewThreadSelector:@selector(createTilesForBoardInThread) toTarget:self withObject:nil];
}


// Methods for managing the moving and placement of Tiles

- (void)updateGrid
{
	// Make click sound
	if (config.soundEnabled)
	{
		AudioServicesPlaySystemSound(tockSSID);
	}

	bool solved = YES;
	for (Tile *tile in tiles)
	{
		// Check if board is solved
		if (![tile solved]) solved = NO;
		
		// Reset move state
		[tile setMoveType:MoveNone];
		[tile setPushTile:nil];
	}
	if (solved)
	{
		self.gameState = GameNotStarted;
		[boardController displaySolvedMenu];
		
		return;
	}
		
	// Go left
	for (int i = 0; (empty.x - 1 - i) >= 0; i++)
	{
		grid[empty.x - 1 - i][empty.y].moveType = MoveRight;
		if (i > 0)
		{
			grid[empty.x - 1 - i][empty.y].pushTile = grid[empty.x - i][empty.y];
		}
	}
	
	// Go right
	for (int i = 0; (empty.x + 1 + i) < config.columns; i++)
	{
		grid[empty.x + 1 + i][empty.y].moveType = MoveLeft;
		if (i > 0)
		{
			grid[empty.x + 1 + i][empty.y].pushTile = grid[empty.x + i][empty.y];
		}
	}
	
	// Go up
	for (int i = 0; (empty.y - 1 - i) >= 0; i++)
	{
		grid[empty.x][empty.y - 1 - i].moveType = MoveDown;
		if (i > 0)
		{
			grid[empty.x][empty.y - 1 - i].pushTile = grid[empty.x][empty.y - i];
		}
	}
	
	// Go down
	for (int i = 0; (empty.y + 1 + i) < config.rows; i++)
	{
		grid[empty.x][empty.y + 1 + i].moveType = MoveUp;
		if (i > 0)
		{
			grid[empty.x][empty.y + 1 + i].pushTile = grid[empty.x][empty.y + i];
		}
	}
}

- (void)moveTileFromCoordinate:(Coordinate)loc1 toCoordinate:(Coordinate)loc2
{
	grid[loc2.x][loc2.y] = grid[loc1.x][loc1.y];
	grid[loc1.x][loc1.y] = NULL;
	
	empty = loc1;
}




#pragma mark Private methods


- (void)createTilesForBoard
{
	// Clean up/remove previous tiles (if exist)
	for (Tile *tile in tiles)
	{
		[tile removeFromSuperview];
	}
	[tiles removeAllObjects];
	[tiles release];
		
	
	CGImageRef imageRef = [self.photo CGImage];
	
	// Calculate tile size
	tileSize = CGSizeMake(trunc(self.frame.size.width / config.columns),
						  trunc(self.frame.size.height / config.rows));
	
	tiles = [[NSMutableArray arrayWithCapacity:(config.columns * config.rows)] retain];
	
	Coordinate loc = { 0, 0 };
	int tileId = 1;
	do
	{
		CGRect tileRect = CGRectMake((loc.x * tileSize.width), (loc.y * tileSize.height), tileSize.width, tileSize.height);
		CGImageRef tileRef = CGImageCreateWithImageInRect(imageRef, tileRect);
		UIImage *tilePhoto = [UIImage imageWithCGImage:tileRef];
		CGImageRelease(tileRef);
				
		Tile *tile = [[Tile tileWithId:tileId board:self loc:loc photo:tilePhoto] retain];
		[tiles addObject:tile];
		[tile release];
		
		if (++loc.x >= config.columns)
		{
			loc.x = 0;
			loc.y++;
		}
		tileId++;
	} while (loc.x < config.columns && (loc.y < config.rows));
	
	// Removed last tile
	[tiles removeLastObject];
	
	
	// Restore previous board state (if applicable)
	if (boardSaved)
	{
		DLog("boardState [%d]", [boardState count]);
		
		for (Tile *tile in tiles)
		{
			NSNumber *num = [NSNumber numberWithInt:tile.tileId];
			
			BoardCoordinate *bc = (BoardCoordinate *) [boardState objectForKey:num];
			if (bc != nil)
			{
				Coordinate savedLoc = { bc.x, bc.y};
				[tile moveToCoordinate:savedLoc];
				grid[bc.x][bc.y] = tile;
			}
			[boardState removeObjectForKey:num];
		}
		
		NSArray *values = [boardState allValues];
		DLog("remaining tiles [%d]", values.count);
		BoardCoordinate *bc = (BoardCoordinate *) [values objectAtIndex:0];
		empty.x = bc.x;
		empty.y = bc.y;
		
		//boardSaved = NO;
	}
		
	// Add tiles to board
	for (Tile *tile in tiles)
	{
		[self addSubview:tile];
	}
	
	[self bringSubviewToFront:pausedView];
	[pausedView setAlpha:1.0f];
}

- (void)scrambleBoard
{
	// Clear grid
	for (int x = 0; x < config.columns; x++)
	{
		for (int y = 0; y < config.rows; y++)
		{
			grid[x][y] = NULL;
		}
	}
	
	NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:tiles.count];
	for (int i = 0; i < (config.rows * config.columns); i++)
	{
		[numberArray insertObject:[NSNumber numberWithInt:i] atIndex:i];
	}
	
	// Scramble Animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kTileScrambleTime];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; 
	[pausedView setAlpha:0];
	
	for (int y = 0; y < config.rows; y++)
	{
		for (int x = 0; x < config.columns; x++)
		{
			if (numberArray.count > 0)
			{
				int randomNum = arc4random() % numberArray.count;
				
#ifdef DEBUG
				//				if (numberArray.count > 2)
				//					randomNum = 0;
				//				else if (numberArray.count == 2)
				//					randomNum = 1;
				//				else
				//					randomNum = 0;
#endif
				
				int index = [[numberArray objectAtIndex:randomNum] intValue];
				[numberArray removeObjectAtIndex:randomNum];
				if (index < tiles.count)
				{
					Tile *tile = [tiles objectAtIndex:index];
					grid[x][y] = tile;
					
					DLog("Add to grid[%d][%d] id[%d]", x, y, tile.tileId);
					
					Coordinate coordinate = { x, y };
					[tile moveToCoordinate:coordinate];
				}
				else
				{
					// Empty slot
					empty.x = x;
					empty.y = y;
					
					DLog(@"Empty slot [%d][%d]", empty.x, empty.y);
				}
			}
		}
	}
	
	[UIView commitAnimations];
	
	[self updateGrid];
}

- (void)restoreGrid
{
	// Clear grid
	for (int x = 0; x < config.columns; x++)
	{
		for (int y = 0; y < config.rows; y++)
		{
			grid[x][y] = NULL;
		}
	}
	
	for (Tile *tile in tiles)
	{
		[self addSubview:tile];
	}
	
	NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:tiles.count];
	for (int i = 0; i < (config.rows * config.columns); i++)
	{
		[numberArray insertObject:[NSNumber numberWithInt:i] atIndex:i];
	}
	
		
	for (int y = 0; y < config.rows; y++)
	{
		for (int x = 0; x < config.columns; x++)
		{
			if (numberArray.count > 0)
			{
				int randomNum = arc4random() % numberArray.count;
				
#ifdef DEBUG
				//				if (numberArray.count > 2)
				//					randomNum = 0;
				//				else if (numberArray.count == 2)
				//					randomNum = 1;
				//				else
				//					randomNum = 0;
#endif
				
				int index = [[numberArray objectAtIndex:randomNum] intValue];
				[numberArray removeObjectAtIndex:randomNum];
				if (index < tiles.count)
				{
					Tile *tile = [tiles objectAtIndex:index];
					grid[x][y] = tile;
					
					DLog("Add to grid[%d][%d] id[%d]", x, y, tile.tileId);
					
					Coordinate coordinate = { x, y };
					[tile moveToCoordinate:coordinate];
				}
				else
				{
					// Empty slot
					empty.x = x;
					empty.y = y;
					
					DLog(@"Empty slot [%d][%d]", empty.x, empty.y);
				}
			}
		}
	}
	
	[UIView commitAnimations];
	
	[self updateGrid];
}


- (void)showWaitView
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:waitImageView];
	[waitImageView startAnimating];
}

- (void)removeWaitView
{
	[waitImageView removeFromSuperview];
	[waitImageView stopAnimating];
	
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		
	if (boardSaved)
	{
		boardSaved = NO;
		gameState = GamePaused;
		[self updateGrid];
		[boardController displayRestartMenu];
	}
	else
	{		
		[boardController displayStartMenu];
	}
}

- (void)createTilesForBoardInThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self createTilesForBoard];
	
	[self performSelectorOnMainThread:@selector(removeWaitView) withObject:self waitUntilDone:NO];
	
	[pool release];
}

- (void)drawBoard
{
	for (Tile *tile in tiles)
	{
		[tile drawTile];
	}
}

- (void)saveBoard
{
	DLog("saveBoard");
	
	if (gameState != GameNotStarted)
	{
		DLog("saving board...");

		NSMutableArray *stateArray = [[NSMutableArray alloc] initWithCapacity:(config.columns * config.rows)];
	
		for (int col = 0; col < config.columns; col++)
		{
			for (int row = 0; row < config.rows; row++)
			{
				Tile *tile = grid[col][row];
				if (tile == nil)
				{
					//DLog("data [%d][%d] nil tile", col, row);
					[stateArray addObject:[NSNumber numberWithInt:0]];
				}
				else
				{
					[stateArray addObject:[NSNumber numberWithInt:tile.tileId]];
					//DLog("data [%d][%d] value [%d]", col, row, tile.tileId);
				}
			}
		}
				
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:stateArray forKey:kKeyBoardState];
		[defaults setBool:YES forKey:kKeyBoardSaved];
		[defaults synchronize];
	
		[stateArray release];
	}
}

- (void)restoreBoard
{
	DLog("restoreBoard");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *stateArray = (NSArray *) [defaults objectForKey:kKeyBoardState];
	boardSaved = [defaults boolForKey:kKeyBoardSaved];
	
	[defaults setBool:NO forKey:kKeyBoardSaved];
	[defaults setObject:nil forKey:kKeyBoardState];
	[defaults synchronize];
	
	if (boardSaved)
	{
		DLog("restoring board...");
		int tileCount = (config.columns * config.rows);
		
		// Check Size
		if ([stateArray count] != tileCount)
		{
			ALog("Saved Board has been corrupted. Number of saves values [%d] different than expected [%d]",
				 [stateArray count], tileCount); 
			boardSaved = NO;
			return;
		}
		
		boardState = [[NSMutableDictionary alloc] initWithCapacity:(config.rows * config.columns)];
		
		for (int i = 0; i < stateArray.count; i++)
		{
			int col = i / config.rows;
			int row = i % config.columns;
			
			NSNumber *num = (NSNumber *) [stateArray objectAtIndex:i];
			[boardState setObject:[[[BoardCoordinate alloc] initWithX:col y:row] autorelease] forKey:num];
				
			//DLog("data [%d][%d] [%d]", col, row, [num intValue]);
			[num release];
		}
	}
}


// END Private Methods

@end
