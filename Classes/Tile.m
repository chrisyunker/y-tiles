//
//  Tile.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/11/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Tile.h"

@interface Tile (Private)

+ (void)setTilePhotoBorderPath;
+ (void)setTileNumberBorderPath;
- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId coord:(Coord)aCoord photo:(UIImage *)aPhoto;
- (void)createPhotoImage;
- (void)createNumberImage;
- (void)updateFrame;
- (CGMutablePathRef)newNumberBorderPathForTextWidth:(float)textWidth;

@end


@implementation Tile

@synthesize tileId;
@synthesize solved;
@synthesize moveType;
@synthesize pushTile;

static CGMutablePathRef tilePhotoBorderPath = NULL;
static CGMutablePathRef tileNumberBorderPath = NULL;
static int tileWidth = 0;
static int tileHeight = 0;


+ (Tile *)tileWithId:(int)aId board:(Board *)aBoard coord:(Coord)aCoord photo:(UIImage *)aPhoto
{
	int height = (int) aPhoto.size.height;
	int width = (int) aPhoto.size.width;
	
	if ((height != tileHeight) || (width != tileWidth))
	{
		tileWidth = width;
		tileHeight = height;
		[Tile setTilePhotoBorderPath];
		[Tile setTileNumberBorderPath];
	}
	
	return [[[Tile alloc] initWithBoard:aBoard tileId:aId coord:aCoord photo:aPhoto] autorelease];
}


- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId coord:(Coord)aCoord photo:(UIImage *)aPhoto
{
	CGRect rect = CGRectMake(0, 0, aPhoto.size.width, aPhoto.size.height);
	
	if (self = [super initWithFrame:rect])
	{		
		board = [aBoard retain];
		photoImage = [aPhoto retain];
		
		tileId = aTileId;
		homeCoord = aCoord;
		coord = aCoord;		
		moveType = None;
		solved = YES;
		haveLock = NO;
		
		[self createNumberImage];
		[self createPhotoImage];
		[self drawTile];
		[self updateFrame];
		[self setUserInteractionEnabled:YES];
		[self setMultipleTouchEnabled:NO];
	}
	return self;
}

- (void)dealloc
{
	//DLog("tileId:[%d]", tileId);
	[photoImage release];
	[numberedPhotoImage release];
	[numberImage release];
	[board release];
    [super dealloc];
}

- (void)drawTile
{
	if (board.config.photoEnabled)
	{
		if (board.config.numbersEnabled)
		{
			[self setImage:numberedPhotoImage];
		}
		else
		{
			[self setImage:photoImage];
		}
	}
	else
	{
		[self setImage:numberImage];
	}
}

- (void)moveToCoord:(Coord)aCoord;
{
	coord.x = aCoord.x;
	coord.y = aCoord.y;
	[self updateFrame];
}

- (void)moveToCoordX:(int)x coordY:(int)y
{
	coord.x = x;
	coord.y = y;
	[self updateFrame];
}
				
- (void)moveInDirection:(Direction)type
{
	// Need to move the furthest tile first
	if (pushTile != nil) [pushTile moveInDirection:type];
	
	Coord prevLoc = coord;
		
	switch (type)
	{
		case Left:
			coord.x--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Right:
			coord.x++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Up:
			coord.y--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Down:
			coord.y++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		default:
			// No move
			break;
	}
	[self updateFrame];
}

- (void)slideInDirection:(Direction)direction distance:(CGFloat)distance
{
	if (pushTile != nil) [pushTile slideInDirection:direction distance:distance];
	
	CGRect frame = [self frame];
	switch (direction)
	{
		case Left:
			frame.origin.x -= distance;
			break;
		case Right:
			frame.origin.x += distance;
			break;
		case Up:
			frame.origin.y -= distance;
			break;
		case Down:
			frame.origin.y += distance;
			break;
        case None:
            break;
	}
	[self setFrame:frame];
}


#pragma mark UIResponder callback methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!moveType) return;
	
	// Get lock
	if ([[board tileLock] tryLock])
	{
		haveLock = YES;
	}
	else
	{		
		return;
	}
	
	// Set start point for sliding tile
	startPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;
		
	CGRect frame = [self frame];
	CGPoint endPoint = [[touches anyObject] locationInView:self];
	
	if (moveType == Up)
	{
		CGFloat initY = frame.origin.y;

		frame.origin.y += endPoint.y - startPoint.y;
		if (frame.origin.y > startOrigin.y) frame.origin.y = startOrigin.y;
		if (frame.origin.y < (startOrigin.y - tileHeight)) frame.origin.y = startOrigin.y - tileHeight;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(initY - frame.origin.y)];		
	}
	else if (moveType == Down)
	{
		CGFloat initY = frame.origin.y;
		
		frame.origin.y += endPoint.y - startPoint.y;
		if (frame.origin.y < startOrigin.y) frame.origin.y = startOrigin.y;
		if (frame.origin.y > (startOrigin.y + tileHeight)) frame.origin.y = startOrigin.y + tileHeight;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(frame.origin.y - initY)];
	}
	else if (moveType == Left)
	{
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += endPoint.x - startPoint.x;
		if (frame.origin.x > startOrigin.x) frame.origin.x = startOrigin.x;
		if (frame.origin.x < (startOrigin.x - tileWidth)) frame.origin.x = startOrigin.x - tileWidth;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(initX - frame.origin.x)];
	}
	else if (moveType == Right)
	{
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += endPoint.x - startPoint.x;
		if (frame.origin.x < startOrigin.x) frame.origin.x = startOrigin.x;
		if (frame.origin.x > (startOrigin.x + tileWidth)) frame.origin.x = startOrigin.x + tileWidth;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(frame.origin.x - initX)];
	}
	
	[self setFrame:frame];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;

	CGRect frame = [self frame];
	if ((frame.origin.x == startOrigin.x) && (frame.origin.y == startOrigin.y))
	{
		// Do nothing
	}
	else if ((frame.origin.x - startOrigin.x) > (tileWidth / 2))
	{		
		// Move Right

		[self moveInDirection:Right];
		[board updateGrid];
	}
	else if ((startOrigin.x - frame.origin.x) > (tileWidth / 2))
	{		
		// Move Left

		[self moveInDirection:Left];
		[board updateGrid];
	}
	else if ((frame.origin.y - startOrigin.y) > (tileHeight / 2))
	{
		// Move Down

		[self moveInDirection:Down];
		[board updateGrid];
	}
	else if ((startOrigin.y - frame.origin.y) > (tileHeight / 2))
	{
		// Move Up

		[self moveInDirection:Up];
		[board updateGrid];
	}
	else
	{
		[self moveInDirection:None];
	}
	
	if (haveLock)
	{
		// Release lock
		[[board tileLock] unlock];
		haveLock = NO;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	DLog("touchesCancelled tileId:[%d]", tileId);

	if (haveLock)
	{
		DLog("Lock Released tileId:[%d]", tileId);
		[[board tileLock] unlock];
		haveLock = NO;
	}	
}


#pragma mark Private methods

- (void)createPhotoImage
{
	CGContextRef context = [Util newBitmapContextForWidth:tileWidth height:tileHeight];

	// Create photo with rounded boarder
	
	CGImageRef baseImageRef = [photoImage CGImage];
	CGContextDrawImage(context, [self frame], baseImageRef);
	
	CGContextSetRGBFillColor(context,
							 kBgColorRed,
							 kBgColorGreen,
							 kBgColorBlue,
							 kBgColorAlpha);
	
	CGContextAddPath(context, tilePhotoBorderPath);
	CGContextEOFillPath(context);
	
	[photoImage release];
	
	CGImageRef photoImageRef = CGBitmapContextCreateImage(context);
	photoImage = [[UIImage imageWithCGImage:photoImageRef] retain];
	CGImageRelease(photoImageRef);
	
	
	// Create tile ID number 
	
	//CGContextSelectFont(context, kPhotoFontType,  kPhotoFontSize, kCGEncodingMacRoman);
	NSString *number = [NSString stringWithFormat:@"%d", tileId];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	//CGContextShowText(context, [number UTF8String], [number length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	
	// Draw background
	CGContextSetRGBFillColor(context,
							 kPhotoBgColorRed,
							 kPhotoBgColorGreen,
							 kPhotoBgColorBlue,
							 kPhotoBgColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	CGMutablePathRef numberBorderPath = [self newNumberBorderPathForTextWidth:textWidth];
	
	CGContextAddPath(context, numberBorderPath);
	CGContextFillPath(context);
	
	// Draw number
	CGContextSetRGBFillColor(context,
							 kPhotoFontColorRed,
							 kPhotoFontColorGreen,
							 kPhotoFontColorBlue,
							 kPhotoFontColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	//CGContextShowTextAtPoint(context,
	//						 (tileWidth - textWidth - kPhotoBgBorder - kPhotoBgOffset),
	//						 (tileHeight - kPhotoFontSize - kPhotoBgOffset),
	//						 [number UTF8String],
	//						 [number length]);
    
    [number drawAtPoint:CGPointMake((tileWidth - textWidth - kPhotoBgBorder - kPhotoBgOffset),
                                    (tileHeight - kPhotoFontSize - kPhotoBgOffset))
        withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@kPhotoFontType
                                                             size:kPhotoFontSize]
                         }];

	
	CGImageRef numberedPhotoImageRef = CGBitmapContextCreateImage(context);
	numberedPhotoImage = [[UIImage imageWithCGImage:numberedPhotoImageRef] retain];
	CGPathRelease(numberBorderPath);
	CGImageRelease(numberedPhotoImageRef);
	
	CGContextRelease(context);
}

- (void)createNumberImage
{
	CGContextRef context = [Util newBitmapContextForWidth:tileWidth height:tileHeight];
	
	// Draw tile
	CGContextSetRGBFillColor(context,
							 kNumberBgColorRed,
							 kNumberBgColorGreen,
							 kNumberBgColorBlue,
							 kNumberBgColorAlpha);
	
	CGContextAddPath(context, tileNumberBorderPath);
	CGContextFillPath(context);
	
	// Draw font
	//CGContextSelectFont(context, kNumberFontType,  kNumberFontSize, kCGEncodingMacRoman);
	NSString *number = [NSString stringWithFormat:@"%d", tileId];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	//CGContextShowText(context, [number UTF8String], [number length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	CGContextSetRGBFillColor(context,
							 kNumberFontColorRed,
							 kNumberFontColorGreen,
							 kNumberFontColorBlue,
							 kNumberFontColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	//CGContextShowTextAtPoint(context,
	//						 ((tileWidth - textWidth) * 0.5),
	//						 ((tileHeight - kNumberFontSize) * 0.5),
	//						 [number UTF8String],
	//						 [number length]);
    
    [number drawAtPoint:CGPointMake(((tileWidth - textWidth) * 0.5),
                                    ((tileHeight - kNumberFontSize) * 0.5))
         withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@kNumberFontType
                                                              size:kNumberFontSize]
                          }];
	
	CGImageRef numberImageRef = CGBitmapContextCreateImage(context);
	
	numberImage = [[UIImage imageWithCGImage:numberImageRef] retain];
	
	CGImageRelease(numberImageRef);
	
	CGContextRelease(context);
}

- (void)updateFrame
{
	startOrigin.x = tileWidth * coord.x;
	startOrigin.y = tileHeight * coord.y;
	
	// Update solved state
	if ((coord.x == homeCoord.x) && (coord.y == homeCoord.y))
	{
		solved = YES;
	}
	else
	{
		solved = NO;
	}
	
	CGRect frame = [self frame];
	frame.origin = startOrigin;
	[self setFrame:frame];
}


- (CGMutablePathRef)newNumberBorderPathForTextWidth:(float)textWidth;
{
	CGMutablePathRef numberBorderPath = CGPathCreateMutable();
	
	CGRect frame = CGRectMake((tileWidth - textWidth - (2 * kPhotoBgBorder) - kPhotoBgOffset),
							  (tileHeight - kPhotoFontSize - kPhotoBgBorder - kPhotoBgOffset),
							  (textWidth + (2 * kPhotoBgBorder)),
							  (kPhotoFontSize + kPhotoBgBorder));
	
	[Util drawRoundedRectForPath:numberBorderPath
							rect:frame
						  radius:kPhotoBgCornerRadius];
	
	return numberBorderPath;
}


// All tiles are the same size so we only need to create
// the rounded border once. The following static methods
// set static CGPathRef variables.

+ (void)setTilePhotoBorderPath
{
	DLog("setTilePhotoBorderPath");
		 
	if (tilePhotoBorderPath != NULL)
	{
		CGPathRelease(tilePhotoBorderPath);
	}
	
	tilePhotoBorderPath = CGPathCreateMutable();
	
	CGPathMoveToPoint(tilePhotoBorderPath, NULL, 0, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileWidth, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileWidth, tileHeight);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, tileHeight);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, 0);
	
	[Util drawRoundedRectForPath:tilePhotoBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											tileWidth,
											tileHeight)
						  radius:kTileCornerRadius];	
}

+ (void)setTileNumberBorderPath
{
	DLog("setTileNumberBorderPath");

	if (tileNumberBorderPath != NULL)
	{
		CGPathRelease(tileNumberBorderPath);
	}
	
	tileNumberBorderPath = CGPathCreateMutable();
	
	[Util drawRoundedRectForPath:tileNumberBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											(tileWidth - (2 * kTileSpacingWidth)),
											(tileHeight - (2 * kTileSpacingWidth)))
						  radius:kTileCornerRadius];	
}

@end
