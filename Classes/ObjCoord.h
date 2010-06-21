//
//  ObjCoord.h
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ObjCoord : NSObject
{
	int x;
	int y;
}

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;

- (id)initWithX:(int)aX y:(int)aY;
- (id)initWithCoord:(ObjCoord *)aCoord;
- (void)setCoord:(ObjCoord *)aCoord;

@end
