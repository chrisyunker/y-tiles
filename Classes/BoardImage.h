//
//  BoardImage.h
//  Y-Tiles
//
//  Created by Chris Yunker on 5/23/10.
//  Copyright 2010 chrisyunker.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Configuration.h"


@interface BoardImage : NSObject
{

}

- (NSArray *)createTilesForImage:(UIImage *)image tileSize:(CGSize)tileSize config:(Configuration *)config;

@end
