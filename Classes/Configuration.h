//
//  Configuration.h
//  Y-Tiles
//
//  Created by Chris Yunker on 2/16/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface Configuration : NSObject
{
	int columns;
	int rows;
	int lastPhotoType;
	BOOL photoEnabled;
	BOOL numbersEnabled;
	BOOL soundEnabled;
}

@property (nonatomic, assign) int columns;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int lastPhotoType;
@property (nonatomic, assign) BOOL photoEnabled;
@property (nonatomic, assign) BOOL numbersEnabled;
@property (nonatomic, assign) BOOL soundEnabled;

- (BOOL)isEqual:(Configuration *)configuration;
- (BOOL)isSizeEqual:(Configuration *)configuration;
- (void)setConfiguration:(Configuration *)configuration;
- (void)load;
- (void)save;

@end
