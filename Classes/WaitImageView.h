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

#define kWaitViewX               0.0f
#define kWaitViewY               20.0f
#define kWaitViewWidth           320.0f
#define kWaitViewHeight          411.0f

#define kWaitViewDialogX         60.0f
#define kWaitViewDialogY         145.0f
#define kWaitViewDialogWidth     200.0f
#define kWaitViewDialogHeight    120.0f

#define kWaitIndicatorX          82.0f
#define kWaitIndicatorY          30.0f
#define kWaitIndicatorWidth      37.0f
#define kWaitIndicatorHeight     37.0f


#define kWaitBgColorRed          55.0f/255.0f
#define kWaitBgColorGreen        182.0f/255.0f
#define kWaitBgColorBlue         206.0f/255.0f
#define kWaitBgColorAlpha        0.5f

#define kWaitViewFontType        "Helvetica Neue"
#define kWaitViewFontSize        26

@interface WaitImageView : UIImageView
{
	UIActivityIndicatorView *activityIndicator;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
