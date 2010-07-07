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
@synthesize photoType;
@synthesize photoEnabled;
@synthesize numbersEnabled;
@synthesize soundEnabled;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{
		board = [aBoard retain];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
	[board release];
	[super dealloc];
}

- (void)load
{
	DLog("Load Configuration");

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	bool savedDefaults = [defaults boolForKey:kKeySavedDefaults];
	if (savedDefaults)
	{
		columns = [defaults integerForKey:kKeyColumns];
		if (columns == 0) columns = kColumnsDefault;
		
		rows = [defaults integerForKey:kKeyRows];
		if (rows == 0) rows = kRowsDefault;
		
		photoType = [defaults integerForKey:kKeylastPhotoType];
		photoEnabled = [defaults boolForKey:kKeyPhotoEnabled];
		numbersEnabled = [defaults boolForKey:kKeyNumbersEnabled];
		soundEnabled = [defaults boolForKey:kKeySoundEnabled];
	}
	else
	{
		columns = kColumnsDefault;
		rows = kRowsDefault;
		photoType = klastPhotoTypeDefault;
		photoEnabled = kPhotoEnabledDefault;
		numbersEnabled = kNumbersEnabledDefault;
		soundEnabled = kSoundEnabledDefault;
	}
}

- (void)save
{
	DLog("Save Configuration");
	BOOL restart = NO;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults integerForKey:kKeyColumns] != columns) { restart = YES; }
	if ([defaults integerForKey:kKeyRows] != rows) { restart = YES; }

	[defaults setBool:YES forKey:kKeySavedDefaults];
	[defaults setInteger:columns forKey:kKeyColumns];
	[defaults setInteger:rows forKey:kKeyRows];
	[defaults setInteger:photoType forKey:kKeylastPhotoType];
	[defaults setBool:photoEnabled forKey:kKeyPhotoEnabled];
	[defaults setBool:numbersEnabled forKey:kKeyNumbersEnabled];
	[defaults setBool:soundEnabled forKey:kKeySoundEnabled];
	[defaults synchronize];
	
	[board configChanged:restart];
}

@end
