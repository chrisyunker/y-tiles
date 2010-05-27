//
//  TestBoardCoordinate.m
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import "TestBoardCoordinate.h"


@implementation TestBoardCoordinate

- (void)setUp
{
}

- (void)testObjectCreation
{
	int x = 1;
	int y = 1;
	
	BoardCoordinate *bc = [[BoardCoordinate alloc] initWithX:x y:y];

	//STAssertEquals(bc.x, x, "X coordinate correct");
	//STAssertEquals(bc.y, y, "Y coordinate correct");
}

- (void)tearDown
{
}

@end
