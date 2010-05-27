//
//  BoardCoordinate.m
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import "BoardCoordinate.h"

@implementation BoardCoordinate

@synthesize x;
@synthesize y;

- (id)initWithX:(int)aX y:(int)aY;
{
	if (self = [super init])
	{
		x = aX;
		y = aY;
	}
	return self;
}
@end
