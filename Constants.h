//
//  Constants.h
//  Y-Tiles
//
//  Created by Chris Yunker on 1/3/09.
//  Copyright Chris Yunker 2009. All rights reserved.
//


#define kVersionMajor            1
#define kVersionMinor            1

// User Default Keys
#define kKeySavedDefaults        @"savedDefaults"
#define kKeyColumns              @"columns"
#define kKeyRows                 @"rows"
#define kKeylastPhotoType        @"lastPhotoType"
#define kKeyPhotoEnabled         @"photoEnabled"
#define kKeyNumbersEnabled       @"numbersEnabled"
#define kKeySoundEnabled         @"soundEnabled"
#define kKeyBoardSaved           @"boardSaved"
#define kKeyBoardState           @"boardState"

// Default Values
#define kColumnsDefault          4
#define kRowsDefault             4
#define klastPhotoTypeDefault    0
#define kPhotoEnabledDefault     YES
#define kNumbersEnabledDefault   NO
#define kSoundEnabledDefault     YES

#define kBoardControllerIndex    0
#define kPhotoControllerIndex    1
#define kSettingsControllerIndex 2
#define kTabBarBoardTag          0
#define kTabBarPhotoTag          1
#define kTabBarSettingsTag       2

#define kRowsMin                 3
#define kRowsMax                 6
#define kColumnsMin              3
#define kColumnsMax              6

#define kBoardX                  0
#define kBoardY                  0
#define kBoardHeight             411
#define kBoardWidth              320

#define kTileSoundName           @"Tock"
#define kTileSoundType           @"aiff"

#define kShakeThresholdHigh      0.5f
#define kShakeThresholdLow       0.2f
#define kShakeCount              3
#define kUpdateInterval          1.0f/30.0f

#define kDocumentsDir            [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define kPhotoType               @"jpg"
#define kDefaultPhoto1           @"DefaultPhoto1"
#define kDefaultPhoto2           @"DefaultPhoto2"
#define kDefaultPhoto3           @"DefaultPhoto3"
#define kDefaultPhoto4           @"DefaultPhoto4"
#define kDefaultPhotoSmall1      @"DefaultPhoto1_sm"
#define kDefaultPhotoSmall2      @"DefaultPhoto2_sm"
#define kDefaultPhotoSmall3      @"DefaultPhoto3_sm"
#define kDefaultPhotoSmall4      @"DefaultPhoto4_sm"
#define kBoardPhoto              @"BoardPhoto.jpg"
#define kDefaultPhoto1Type       0
#define kDefaultPhoto2Type       1
#define kDefaultPhoto3Type       2
#define kDefaultPhoto4Type       3
#define kBoardPhotoType          4
#define kWebUrl                  @"http://m.chrisyunker.com"
#define kEmailUrl                @"mailto:ytiles@chrisyunker.com"

#define kTileSpacingWidth        1.0f
#define kTileCornerRadius        10.0f

#define kPausedImageColorRed     130.0f/255.0f
#define kPausedImageColorGreen   130.0f/255.0f 
#define kPausedImageColorBlue    130.0f/255.0f
#define kPausedImageColorAlpha   0.5f

#define kBgColorRed              0.0f
#define kBgColorGreen            0.0f
#define kBgColorBlue             0.0f
#define kBgColorAlpha            1.0f

#define kTileScrambleTime        1.0f
#define kMenuFadeTime            1.0f

// Number Mode
#define kNumberFontColorRed      0.0f
#define kNumberFontColorGreen    0.0f
#define kNumberFontColorBlue     0.0f
#define kNumberFontColorAlpha    1.0f

#define kNumberBgColorRed        55.0f/255.0f
#define kNumberBgColorGreen      182.0f/255.0f
#define kNumberBgColorBlue       206.0f/255.0f
#define kNumberBgColorAlpha      1.0f

#define kNumberFontType          "Helvetica"
#define kNumberFontSize          20

// Photo Mode
#define kPhotoFontColorRed       0.0f
#define kPhotoFontColorGreen     0.0f
#define kPhotoFontColorBlue      0.0f
#define kPhotoFontColorAlpha     1.0f

#define kPhotoBgColorRed         1.0f
#define kPhotoBgColorGreen       1.0f
#define kPhotoBgColorBlue        1.0f
#define kPhotoBgColorAlpha       0.5f

#define kPhotoBgBorder           5.0f
#define kPhotoBgOffset           10.0f
#define kPhotoBgCornerRadius     5.0f

#define kPhotoFontType           "Helvetica"
#define kPhotoFontSize           20
