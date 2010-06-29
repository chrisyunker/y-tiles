//
//  WaitImageView.h
//  Y-Tiles
//
//  Created by Chris Yunker on 3/1/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Util.h"

#define kWaitViewX               75.0f
#define kWaitViewY               145.0f
#define kWaitViewWidth           170.0f
#define kWaitViewHeight          120.0f

#define kWaitViewBgColorRed      0.0f
#define kWaitViewBgColorGreen    0.0f
#define kWaitViewBgColorBlue     0.0f
#define kWaitViewBgColorAlpha    0.75f

#define kWaitViewFontColorRed    1.0f
#define kWaitViewFontColorGreen  1.0f
#define kWaitViewFontColorBlue   1.0f
#define kWaitViewFontColorAlpha  1.0f

#define kWaitIndicatorX          67.0f
#define kWaitIndicatorY          30.0f
#define kWaitIndicatorWidth      37.0f
#define kWaitIndicatorHeight     37.0f

#define kWaitViewFontType        "Helvetica"
#define kWaitViewFontSize        26

@interface WaitImageView : UIImageView
{
	UIActivityIndicatorView *activityIndicator;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
