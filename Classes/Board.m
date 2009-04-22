//
//  Board.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Board.h"

@interface Board (Private)

- (void)freeNumberBorderPaths;
- (void)createPausedView;
- (void)createTilesForBoard;
- (void)scrambleBoard;
- (void)showWaitView;
- (void)removeWaitView;
- (void)createTilesForBoardInThread;
- (void)drawBoard;

@end


@implementation Board

@synthesize photo;
@synthesize config;
@synthesize tileLock;
@synthesize gameState;
@synthesize boardController;
@synthesize lastAcceleration;

- (id)init
{
	if (self = [super initWithFrame:CGRectMake(kBoardX, kBoardY, kBoardWidth, kBoardHeight)])
	{
		config = [[Configuration alloc] init];
		[config load];
		
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
		
		switch (config.lastPhotoType)
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
				break;
		}
		
		waitImageView = [[WaitImageView alloc] init];
		[self createPausedView];
		[self addSubview:pausedView];
		
		gameState = GamePaused;
		tilePhotoBorderPath = NULL;
		tileNumberBorderPath = NULL;
		numberBorderPaths = CFDictionaryCreateMutable(NULL, 0,
													  &kCFTypeDictionaryKeyCallBacks,
													  &kCFTypeDictionaryValueCallBacks);

		NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
		NSURL *url = [NSURL fileURLWithPath:[uiKitBundle pathForResource:kTileSoundName ofType:kTileSoundType]];
		OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef) url, &tockSSID);
		if (error) ALog(@"Board:init Failed to create sound for URL [%@]", url);
		
		accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
		accelerometer.delegate = self;
		accelerometer.updateInterval = kUpdateInterval;
		shakeCount = 0;
		
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
	
	[self freeNumberBorderPaths];
	CFRelease(numberBorderPaths);
	CGPathRelease(tilePhotoBorderPath);
	CGPathRelease(tileNumberBorderPath);
	
	AudioServicesDisposeSystemSoundID(tockSSID);
	[config release];
	[pausedView release];
	[waitImageView release];
	[photo release];
	[boardTiles release];
	[tileLock release];
	[boardController release];
	[accelerometer release];
	[lastAcceleration release];
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
	gameState = state;
	
	switch (gameState)
	{
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

- (void)setConfiguration:(Configuration *)aConfiguration
{
	if (![config isSizeEqual:aConfiguration])
	{
		self.gameState = GamePaused;

		[config setConfiguration:aConfiguration];
		[config save];
				
		// Create New Board
		[self showWaitView];
		[NSThread detachNewThreadSelector:@selector(createTilesForBoardInThread) toTarget:self withObject:nil];
	}
	else if (![config isEqual:aConfiguration])
	{
		[config setConfiguration:aConfiguration];
		[config save];
		
		// Board just needs to be redrawn
		[self drawBoard];		
	}
}

- (void)setPhoto:(UIImage *)aPhoto type:(int)aType
{
	self.gameState = GamePaused;

	self.photo = aPhoto;
	
	config.lastPhotoType = aType;
	config.photoEnabled = YES;
	[config save];
	
	[self showWaitView];
	[NSThread detachNewThreadSelector:@selector(createTilesForBoardInThread) toTarget:self withObject:nil];
}


// Methods for managing the moving and placemnt of Tiles

- (void)updateGrid
{
	// Make click sound
	if (config.soundEnabled)
	{
		AudioServicesPlaySystemSound(tockSSID);
	}

	bool solved = YES;
	for (Tile *tile in boardTiles)
	{
		// Check if board is solved
		if (![tile solved]) solved = NO;
		
		// Reset move state
		[tile setMoveType:MoveNone];
		[tile setPushTile:nil];
	}
	if (solved)
	{
		self.gameState = GamePaused;
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


// Methods for creating/reusing CGPaths for Tiles

- (CGMutablePathRef)getTilePhotoBorderPath
{	
	if (tilePhotoBorderPath != NULL)
	{
		return tilePhotoBorderPath;
	}

	tilePhotoBorderPath = CGPathCreateMutable();
	
	CGPathMoveToPoint(tilePhotoBorderPath, NULL, 0, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileSize.width, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileSize.width, tileSize.height);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, tileSize.height);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, 0);
	
	[Util drawRoundedRectForPath:tilePhotoBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											tileSize.width,
											tileSize.height)
						  radius:kTileCornerRadius];
	
	return tilePhotoBorderPath;
}

- (CGMutablePathRef)getTileNumberBorderPath
{	
	if (tileNumberBorderPath != NULL)
	{
		return tileNumberBorderPath;
	}
	
	tileNumberBorderPath = CGPathCreateMutable();
	
	[Util drawRoundedRectForPath:tileNumberBorderPath
							rect:CGRectMake(kTileSpacingWidth,
										   kTileSpacingWidth,
										   (tileSize.width - (2 * kTileSpacingWidth)),
										   (tileSize.height - (2 * kTileSpacingWidth)))
							radius:kTileCornerRadius];
	
	return tileNumberBorderPath;
}

 - (CGMutablePathRef)getNumberBorderPathForTextWidth:(float)textWidth;
{
	CFNumberRef textWidthRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &textWidth);
	
	CGMutablePathRef numberBorderPath = (CGMutablePathRef) CFDictionaryGetValue(numberBorderPaths, textWidthRef);	
	if (numberBorderPath != nil)
	{
		CFRelease(textWidthRef);
		
		return numberBorderPath;
	}

	numberBorderPath = CGPathCreateMutable();

	CGRect frame = CGRectMake((tileSize.width - textWidth - (2 * kPhotoBgBorder) - kPhotoBgOffset),
							  (tileSize.height - kPhotoFontSize - kPhotoBgBorder - kPhotoBgOffset),
							  (textWidth + (2 * kPhotoBgBorder)),
							  (kPhotoFontSize + kPhotoBgBorder));
	
	[Util drawRoundedRectForPath:numberBorderPath
							rect:frame
						  radius:kPhotoBgCornerRadius];
	
	CFDictionarySetValue(numberBorderPaths, textWidthRef, numberBorderPath);
	
	return numberBorderPath;
}



#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	selectedViewController = viewController.tabBarController.selectedIndex;
}


#pragma mark UIAccelerometerDelegate methods

- (BOOL)thresholdShakeLast:(UIAcceleration *)last current:(UIAcceleration *)current threshold:(double)threshold
{
	double diffX = fabs(last.x - current.x);
	double diffY = fabs(last.y - current.y);
	double diffZ = fabs(last.z - current.z);
	
	if ((diffX > threshold) && (diffY > threshold) ||
		(diffY > threshold) && (diffZ > threshold) ||
		(diffZ > threshold) && (diffX > threshold))
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if (self.lastAcceleration)
	{
		if ([self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdHigh] &&
			shakeCount > kShakeCount)
		{
			if (selectedViewController == kBoardControllerIndex)
			{
				if (self.gameState == GameInProgress)
				{
					self.gameState = GamePaused;
					[boardController displayRestartMenu];
				}
			}
						
			shakeCount = 0;
        }
		else if ([self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdHigh])
		{
			shakeCount += 1;
        }
		else if (![self thresholdShakeLast:self.lastAcceleration current:acceleration threshold:kShakeThresholdLow])
		{
			if (shakeCount > 0)
			{
				shakeCount -= 1;
			}
        }
	}
	
	self.lastAcceleration = acceleration;
}


#pragma mark Private methods

- (void)freeNumberBorderPaths
{
	const void **keys = 0;
	const void **values = 0;
	CFIndex count = CFDictionaryGetCount(numberBorderPaths);
	keys = (const void **)malloc(sizeof(void *) * count);
	values = (const void **)malloc(sizeof(void *) * count);
	CFDictionaryGetKeysAndValues(numberBorderPaths, keys, values);
	CFDictionaryRemoveAllValues(numberBorderPaths);
	for (CFIndex i = 0; i < count; i++)
	{
		CFNumberRef numberRef = (CFNumberRef) keys[i];
		CFRelease(numberRef);
		CGMutablePathRef pathRef = (CGMutablePathRef) values[i];
		CGPathRelease(pathRef);
	}
	free ((void *) keys);
	free ((void *) values);
}

- (void)createPausedView
{
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();	
	
    CGContextRef context = CGBitmapContextCreate(NULL,
												 self.frame.size.width,
												 self.frame.size.height,
												 8,
												 (self.frame.size.width * 4),
												 colorSpaceRef,
												 kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpaceRef);
	
	CGContextSetRGBFillColor(context,
							 kPausedImageColorRed,
							 kPausedImageColorGreen,
							 kPausedImageColorBlue,
							 kPausedImageColorAlpha);
	
	CGContextFillRect(context, self.frame);
	
	CGImageRef pausedImageRef = CGBitmapContextCreateImage(context);
	UIImage *pausedImage = [UIImage imageWithCGImage:pausedImageRef];
	
	CGImageRelease(pausedImageRef);
	CGContextRelease(context);
	
	pausedView = [[UIImageView alloc] initWithFrame:self.frame];
	pausedView.image = pausedImage;
	pausedView.userInteractionEnabled = NO;
}

- (void)createTilesForBoard
{
	for (Tile *tile in boardTiles)
	{
		[tile removeFromSuperview];
	}
	[boardTiles removeAllObjects];
	[boardTiles release];
	
	// Free CGPath resources, if needed
	if (tilePhotoBorderPath != NULL)
	{
		CGPathRelease(tilePhotoBorderPath);
		tilePhotoBorderPath = NULL;
	}
	if (tileNumberBorderPath != NULL)
	{
		CGPathRelease(tileNumberBorderPath);
		tileNumberBorderPath = NULL;
	}
	[self freeNumberBorderPaths];
	
	CGImageRef imageRef = [self.photo CGImage];
	
	// Calculate tile size
	tileSize = CGSizeMake(trunc(self.frame.size.width / config.columns),
						  trunc(self.frame.size.height / config.rows));
	
	boardTiles = [[NSMutableArray arrayWithCapacity:(config.columns * config.rows)] retain];
	
	Coordinate loc = { 0, 0 };
	int tileId = 1;
	do
	{
		CGRect tileRect = CGRectMake((loc.x * tileSize.width), (loc.y * tileSize.height), tileSize.width, tileSize.height);
		CGImageRef tileRef = CGImageCreateWithImageInRect(imageRef, tileRect);
		UIImage *tilePhoto = [UIImage imageWithCGImage:tileRef];
		CGImageRelease(tileRef);
		
		Tile *tile = [[Tile alloc] initWithBoard:self tileId:tileId loc:loc photo:tilePhoto];
		
		[boardTiles addObject:tile];
		[tile release];
		
		if (++loc.x >= config.columns)
		{
			loc.x = 0;
			loc.y++;
		}
		tileId++;
	} while (loc.x < config.columns && (loc.y < config.rows));
	
	// Removed last tile
	[boardTiles removeLastObject];
	
	// Add tiles to board
	for (Tile *tile in boardTiles)
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
	
	NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:boardTiles.count];
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
				if (index < boardTiles.count)
				{
					Tile *tile = [boardTiles objectAtIndex:index];
					grid[x][y] = tile;
					
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
	
	[boardController displayStartMenu];
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
	for (Tile *tile in boardTiles)
	{
		[tile drawTile];
	}
}

// END Private Methods

@end
