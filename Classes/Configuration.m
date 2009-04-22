//
//  Configuration.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/16/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

@synthesize columns;
@synthesize rows;
@synthesize lastPhotoType;
@synthesize photoEnabled;
@synthesize numbersEnabled;
@synthesize soundEnabled;

- (void)load
{
	DLog(@"load");

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	bool savedDefaults = [defaults boolForKey:kKeySavedDefaults];
	if (savedDefaults)
	{
		columns = [defaults integerForKey:kKeyColumns];
		if (columns == 0) columns = kColumnsDefault;
		
		rows = [defaults integerForKey:kKeyRows];
		if (rows == 0) rows = kRowsDefault;
		
		lastPhotoType = [defaults integerForKey:kKeylastPhotoType];
		photoEnabled = [defaults boolForKey:kKeyPhotoEnabled];
		numbersEnabled = [defaults boolForKey:kKeyNumbersEnabled];
		soundEnabled = [defaults boolForKey:kKeySoundEnabled];
	}
	else
	{
		columns = kColumnsDefault;
		rows = kRowsDefault;
		lastPhotoType = klastPhotoTypeDefault;
		photoEnabled = kPhotoEnabledDefault;
		numbersEnabled = kNumbersEnabledDefault;
		soundEnabled = kSoundEnabledDefault;
	}
}

- (void)save
{
	DLog(@"save");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:kKeySavedDefaults];
	[defaults setInteger:columns forKey:kKeyColumns];
	[defaults setInteger:rows forKey:kKeyRows];
	[defaults setInteger:lastPhotoType forKey:kKeylastPhotoType];
	[defaults setBool:photoEnabled forKey:kKeyPhotoEnabled];
	[defaults setBool:numbersEnabled forKey:kKeyNumbersEnabled];
	[defaults setBool:soundEnabled forKey:kKeySoundEnabled];
	[defaults synchronize];	
}

- (BOOL)isEqual:(Configuration *)configuration
{
	// No need to compare lastPhotoType field
	
	if ((columns == configuration.columns) &&
		(rows == configuration.rows) &&
		(photoEnabled == configuration.photoEnabled) &&
		(numbersEnabled == configuration.numbersEnabled) &&
		(soundEnabled == configuration.soundEnabled))
	{
		return YES;
	}
	else
	{
		return NO;
	}
	
}

- (BOOL)isSizeEqual:(Configuration *)configuration
{
	if ((columns == configuration.columns) &&
		(rows == configuration.rows))
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)setConfiguration:(Configuration *)configuration
{
	columns = configuration.columns;
	rows = configuration.rows;
	lastPhotoType = configuration.lastPhotoType;
	photoEnabled = configuration.photoEnabled;
	numbersEnabled = configuration.numbersEnabled;
	soundEnabled = configuration.soundEnabled;
}

@end
