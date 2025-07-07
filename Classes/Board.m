//
//  Board.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import "Board.h"

@implementation Board

@synthesize photo;
@synthesize config;
@synthesize tileLock;
@synthesize gameState;
@synthesize boardController;
@synthesize size;

- (id)initWithSize:(CGSize)aSize;
{
    size = aSize;
    DLog("Create board size width:%f, height:%f", size.width, size.height);
    
	if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)])
	{
		config = [[Configuration alloc] initWithBoard:self];
		[config load];
				
		tileLock = [[NSLock alloc] init];
		
		// Create grid to handle largest possible configuration
		grid = (__strong Tile ***)malloc(kColumnsMax * sizeof(Tile **));
		if (grid == NULL)
		{
			ALog("Board:init Memory allocation error");
			return nil;
		}
		for (int x = 0; x < kColumnsMax; x++)
		{
			grid[x] = (__strong Tile **)malloc(kRowsMax * sizeof(Tile *));
			if (grid[x] == NULL)
			{
				ALog("Board:init Memory allocation error");
				return nil;
			}
		}
		
        switch ([config photoType])
        {
            case kDefaultPhoto1Type:
                [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                           pathForResource:kDefaultPhoto1
                                                                           ofType:kPhotoType]]];
                break;
            case kDefaultPhoto2Type:
                [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                           pathForResource:kDefaultPhoto2
                                                                           ofType:kPhotoType]]];
                break;
            case kDefaultPhoto3Type:
                [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                           pathForResource:kDefaultPhoto3
                                                                           ofType:kPhotoType]]];
                break;
            case kDefaultPhoto4Type:
                [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                           pathForResource:kDefaultPhoto4
                                                                           ofType:kPhotoType]]];
                break;
            case kBoardPhotoType:
                [self cropPhoto:[UIImage imageWithContentsOfFile:[kDocumentsDir stringByAppendingPathComponent:kBoardPhoto]]];
                if ([self photo] == nil)
                {
                    ALog("Board:init Failed to load last board image [%@]",
                         [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto]);
                    
                    [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                               pathForResource:kDefaultPhoto1
                                                                               ofType:kPhotoType]]];
                }
                break;
            default:
                [self cropPhoto:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                           pathForResource:kDefaultPhoto1
                                                                           ofType:kPhotoType]]];
        }
		
		[self restoreBoard];
				
        waitImageView = [[WaitImageView alloc] initWithSize:size];
		pausedView = [Util createPausedViewWithFrame:[self frame]];
		[self addSubview:pausedView];
        
		// Tile move tick sound
        NSURL *tockUrl = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Tock.caf"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:tockUrl error:NULL];
        [player setVolume:1.0];
        		
		[self setBackgroundColor:[UIColor blackColor]];
		[self setMultipleTouchEnabled:NO];
		[self setGameState:GameNotStarted];
	}
	
    return self;
}

- (void)dealloc
{
	DLog("dealloc");
	
	// Free 2D grid array
	for (int i = 0; i < kColumnsMax; i++)
	{
		if (grid[i]) free(grid[i]);
	}
	if (grid) free(grid);
}

- (void)createNewBoard
{
	[self showWaitView];
    [self createTiles];
    [self removeWaitView];
}

- (void)restart
{
    if ([self gameState] == GameInProgress)
    {
        [self setGameState:GamePaused];
        [boardController displayRestartMenu];
    }
    [[boardController tabBarController] setSelectedIndex:kBoardControllerIndex];
}

- (void)start
{
	[self scrambleBoard];
	[self updateGrid];
	[self setGameState:GameInProgress];
}

- (void)pause
{
	[self setGameState:GamePaused];
}

- (void)resume
{
	[self updateGrid];
	[self setGameState:GameInProgress];
}

- (void)setGameState:(GameState)state
{
	DLog("Old State [%d] -> New State [%d]", gameState, state);
	
	gameState = state;
	
	switch (gameState)
	{
		case GameNotStarted:
		case GamePaused:
			[self showPausedView:YES];

			break;
		case GameInProgress:
			[self showPausedView:NO];
			
			break;
		default:
			break;
	}
}

- (void)configChanged:(BOOL)restart
{
	if (restart)
	{
		[self createNewBoard];
	}
	else	
	{
		[self drawBoard];		
	}
}

- (void)setPhoto:(UIImage *)aPhoto type:(int)aType
{
	[self cropPhoto:aPhoto];
	
	[config setPhotoType:aType];
	[config setPhotoEnabled:YES];
	[config save];
	
	[self createNewBoard];
}

- (void)cropPhoto:(UIImage *)image
{
    CGFloat x = MAX(0, image.size.width - self.size.width) / 2;
    CGFloat y = MAX(0, image.size.height - self.size.height) / 2;
    CGRect cropRect = CGRectMake(x, y, self.size.width, self.size.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    self.photo = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
}


// Methods for managing the moving and placement of Tiles

- (void)updateGrid
{
	// Make click sound
	if (config.soundEnabled)
	{
        [player play];
	}

	bool solved = YES;
	for (Tile *tile in tiles)
	{
		// Check if board is solved
		if (![tile solved]) solved = NO;
		
		// Reset move state
		[tile setMoveType:None];
		[tile setPushTile:nil];
	}
	if (solved)
	{
		[self setGameState:GameNotStarted];
		[boardController displaySolvedMenu];
		
		return;
	}
		
	// Go left
	for (int i = 0; (empty.x - 1 - i) >= 0; i++)
	{
		grid[empty.x - 1 - i][empty.y].moveType = Right;
		if (i > 0)
		{
			grid[empty.x - 1 - i][empty.y].pushTile = grid[empty.x - i][empty.y];
		}
	}
	
	// Go right
	for (int i = 0; (empty.x + 1 + i) < config.columns; i++)
	{
		grid[empty.x + 1 + i][empty.y].moveType = Left;
		if (i > 0)
		{
			grid[empty.x + 1 + i][empty.y].pushTile = grid[empty.x + i][empty.y];
		}
	}
	
	// Go up
	for (int i = 0; (empty.y - 1 - i) >= 0; i++)
	{
		grid[empty.x][empty.y - 1 - i].moveType = Down;
		if (i > 0)
		{
			grid[empty.x][empty.y - 1 - i].pushTile = grid[empty.x][empty.y - i];
		}
	}
	
	// Go down
	for (int i = 0; (empty.y + 1 + i) < config.rows; i++)
	{
		grid[empty.x][empty.y + 1 + i].moveType = Up;
		if (i > 0)
		{
			grid[empty.x][empty.y + 1 + i].pushTile = grid[empty.x][empty.y + i];
		}
	}
}

- (void)moveTileFromCoordinate:(Coord)coord1 toCoordinate:(Coord)coord2
{
	grid[coord2.x][coord2.y] = grid[coord1.x][coord1.y];
	grid[coord1.x][coord1.y] = NULL;
	
	empty = coord1;
}

- (void)createTiles
{
	// Clean up/remove previous tiles (if exist)
	for (Tile *tile in tiles)
	{
		[tile removeFromSuperview];
	}
	[tiles removeAllObjects];

    CGImageRef imageRef = CGImageCreateWithImageInRect([photo CGImage], CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	    
    // Calculate tile size
    CGSize tileSize = CGSizeMake(trunc(self.frame.size.width / config.columns),
                                 trunc(self.frame.size.height / config.rows));
    
	tiles = [NSMutableArray arrayWithCapacity:(config.columns * config.rows)];
	
	Coord coord = { 0, 0 };
	int tileId = 1;
	do
	{
		CGRect tileRect = CGRectMake((coord.x * tileSize.width), (coord.y * tileSize.height), tileSize.width, tileSize.height);
		CGImageRef tileRef = CGImageCreateWithImageInRect(imageRef, tileRect);
		UIImage *tilePhoto = [UIImage imageWithCGImage:tileRef];
		CGImageRelease(tileRef);
                
		Tile *tile = [Tile tileWithId:tileId
								 board:self
								 coord:coord
								 photo:tilePhoto];
        
		[tiles addObject:tile];
		
		if (++coord.x >= config.columns)
		{
			coord.x = 0;
			coord.y++;
		}
        
		tileId++;
        
	} while (coord.x < config.columns && (coord.y < config.rows));
	
	// Removed last tile
	[tiles removeLastObject];
	
	// Restore previous board state (if applicable)
	if (boardSaved)
	{		
		for (Tile *tile in tiles)
		{
			NSNumber *tileId = [NSNumber numberWithInt:[tile tileId]];
			NSArray *coord = (NSArray *) [boardState objectForKey:tileId];
			if (coord != nil)
			{
				int x = [(NSNumber *) [coord objectAtIndex:0] intValue];
				int y = [(NSNumber *) [coord objectAtIndex:1] intValue];
				
				[tile moveToCoordX:x coordY:y];
				grid[x][y] = tile;
			}
		}
		
		NSArray *coord = (NSArray *) [boardState objectForKey:[NSNumber numberWithInt:0]];
		empty.x = [(NSNumber *) [coord objectAtIndex:0] intValue];
		empty.y = [(NSNumber *) [coord objectAtIndex:1] intValue];
		
		[boardState removeAllObjects];
	}
		
	// Add tiles to board
	for (Tile *tile in tiles)
	{
		[self addSubview:tile];
	}
	
	if (boardSaved)
	{
		[self setGameState:GamePaused];
	}
	else
	{
		[self setGameState:GameNotStarted];
	}
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
	[UIView animateWithDuration:kTileScrambleTime
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        for (int y = 0; y < self->config.rows; y++)
		{
            for (int x = 0; x < self->config.columns; x++)
			{
				if (numberArray.count > 0)
				{
					int randomNum = arc4random() % numberArray.count;
					
#ifdef DEBUG
//								if (numberArray.count > 2)
//									randomNum = 0;
//								else if (numberArray.count == 2)
//									randomNum = 1;
//								else
//									randomNum = 0;
#endif
					
					int index = [[numberArray objectAtIndex:randomNum] intValue];
					[numberArray removeObjectAtIndex:randomNum];
                    if (index < self->tiles.count)
					{
                        Tile *tile = [self->tiles objectAtIndex:index];
                        self->grid[x][y] = tile;
											
						[tile moveToCoordX:x coordY:y];
					}
					else
					{
						// Empty slot
                        self->empty.x = x;
                        self->empty.y = y;
						
                        DLog("Empty slot [%d][%d]", self->empty.x, self->empty.y);
					}
				}
			}
		}
	} completion:nil];	
}

- (void)showWaitView
{
	[self setUserInteractionEnabled:NO];
	
	[boardController removeMenu];
	[waitImageView startAnimating];
    
	[self addSubview:waitImageView];
	
	[[boardController tabBarController] setSelectedIndex:kBoardControllerIndex];
}

- (void)removeWaitView
{	
	[waitImageView removeFromSuperview];
	[waitImageView stopAnimating];
	
	if (boardSaved)
	{
		boardSaved = NO;
		[boardController displayRestartMenu];
	}
	else
	{
		[boardController displayStartMenu];
	}
	
	[self setUserInteractionEnabled:YES];
}

- (void)showPausedView:(BOOL)enabled
{
	if (enabled)
	{
		[self setUserInteractionEnabled:NO];
		[pausedView setAlpha:1.0f];
		[self bringSubviewToFront:pausedView];
	}
	else
	{
		[self setUserInteractionEnabled:YES];
		[pausedView setAlpha:0.0f];
		[self sendSubviewToBack:pausedView];
	}
}

- (void)createTilesInThread
{
	@autoreleasepool {
		[self createTiles];
		
		[self performSelectorOnMainThread:@selector(removeWaitView) withObject:self waitUntilDone:NO];
	}
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
		DLog("Saving board...");

		NSMutableArray *stateArray = [[NSMutableArray alloc] initWithCapacity:(config.columns * config.rows)];
	
		for (int y = 0; y < config.rows; y++)
		{
			for (int x = 0; x < config.columns; x++)
			{
				Tile *tile = grid[x][y];
				if (tile == nil)
				{
					[stateArray addObject:[NSNumber numberWithInt:0]];
				}
				else
				{
					[stateArray addObject:[NSNumber numberWithInt:[tile tileId]]];
				}
			}
		}
				
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:stateArray forKey:kKeyBoardState];
		[defaults setBool:YES forKey:kKeyBoardSaved];
		[defaults synchronize];
	}
}

- (void)restoreBoard
{
	DLog("restoreBoard");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	boardSaved = [defaults boolForKey:kKeyBoardSaved];
	
	if (boardSaved)
	{
		DLog("Restoring board...");
		
		NSArray *stateArray = (NSArray *) [defaults objectForKey:kKeyBoardState];
		
		[defaults setBool:NO forKey:kKeyBoardSaved];
		[defaults removeObjectForKey:kKeyBoardState];
		[defaults synchronize];
		
		int tileCount = (config.columns * config.rows);
		
		// Check Size
		if ([stateArray count] != tileCount)
		{
			ALog("Saved Board has been corrupted. Number of saves values [%lu] different than expected [%d]",
				 (unsigned long)[stateArray count], tileCount);
			boardSaved = NO;
			return;
		}
		
		boardState = [[NSMutableDictionary alloc] initWithCapacity:(config.rows * config.columns)];
		
		for (int i = 0; i < stateArray.count; i++)
		{
			int y = i / config.columns;
			int x = i % config.columns;
			
			NSNumber *tileId = (NSNumber *) [stateArray objectAtIndex:i];
			NSArray *coord = @[[NSNumber numberWithInt:x], [NSNumber numberWithInt:y]];

			[boardState setObject:coord forKey:tileId];
		}
	}
}

@end
