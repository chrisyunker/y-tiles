//
//  BoardImage.m
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import "BoardImage.h"

#import "Tile.h"


@implementation BoardImage

- (NSArray *)createTilesForImage:(UIImage *)image tileSize:(CGSize)tileSize config:(Configuration *)config
{
	NSMutableArray *tiles = [[NSMutableArray alloc] initWithCapacity:(config.rows * config.columns)];
	
	CGImageRef imageRef = [image CGImage];
	
	Coordinate loc = { 0, 0 };
	int tileId = 1;
	do
	{
		CGRect tileRect = CGRectMake((loc.x * tileSize.width), (loc.y * tileSize.height), tileSize.width, tileSize.height);
		CGImageRef tileRef = CGImageCreateWithImageInRect(imageRef, tileRect);
		UIImage *tilePhoto = [UIImage imageWithCGImage:tileRef];
		CGImageRelease(tileRef);
		
		Tile *tile = [[Tile alloc] initWithBoard:self tileId:tileId loc:loc photo:tilePhoto];
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
	
	[tiles autorelease];
	return tiles;	
}


@end

