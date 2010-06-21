//
//  ObjCoord.m
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import "ObjCoord.h"

@implementation ObjCoord

@synthesize x;
@synthesize y;

- (id)initWithX:(int)aX y:(int)aY
{
	if (self = [super init])
	{
		x = aX;
		y = aY;
	}
	return self;
}

- (id)initWithCoord:(ObjCoord *)aCoord
{
	if (self = [super init])
	{
		x = aCoord.x;
		y = aCoord.y;
	}
	return self;
}

- (void)setCoord:(ObjCoord *)aCoord
{
	x = aCoord.x;
	y = aCoord.y;
}

@end
