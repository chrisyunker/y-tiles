//
//  WaitImageView.h
//  Y-Tiles
//
//  Created by Chris Yunker on 3/1/09.
//  Copyright 2025 chrisyunker.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Constants.h"
#import "Util.h"

@interface WaitImageView : UIImageView
{
	UIActivityIndicatorView *activityIndicator;
}

- (id)initWithSize:(CGSize)size;
- (void)startAnimating;
- (void)stopAnimating;

@end
