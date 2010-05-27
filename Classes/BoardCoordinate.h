//
//  BoardCoordinate.h
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BoardCoordinate : NSObject
{
	int x;
	int y;
}

@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;

- (id)initWithX:(int)aX y:(int)aY;

@end
