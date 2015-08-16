//
//  PhotoDefaultController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/26/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import "PhotoDefaultController.h"

@interface PhotoDefaultController (Private)

- (void)selectPhotoWithPath:(NSString *)path type:(int)type;

@end


@implementation PhotoDefaultController

@synthesize defaultPhoto1;
@synthesize defaultPhoto2;
@synthesize defaultPhoto3;
@synthesize defaultPhoto4;
@synthesize cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photoController:(PhotoController *)aPhotoController
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		photoController = [aPhotoController retain];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
	[defaultPhoto1 release], defaultPhoto1 = nil;
	[defaultPhoto2 release], defaultPhoto2 = nil;
	[defaultPhoto3 release], defaultPhoto3 = nil;
	[defaultPhoto4 release], defaultPhoto4 = nil;
	[cancelButton release], cancelButton = nil;
	[photoController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog("didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)setView:(UIView *)aView
{	
	if (aView == nil)
	{
		DLog("Setting view to nil due to low memory");

		[self setDefaultPhoto1:nil];
		[self setDefaultPhoto2:nil];
		[self setDefaultPhoto3:nil];
		[self setDefaultPhoto4:nil];
		[self setCancelButton:nil];
	}
	
    [super setView:aView];
}

- (void)viewDidLoad 
{	
	[super viewDidLoad];
	
	UIImage *photo1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															   pathForResource:kDefaultPhotoSmall1
															   ofType:kPhotoType]];
	[defaultPhoto1 setBackgroundImage:photo1 forState:UIControlStateNormal];
	[photo1 release];
	
	UIImage *photo2 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															   pathForResource:kDefaultPhotoSmall2
															   ofType:kPhotoType]];
	[defaultPhoto2 setBackgroundImage:photo2 forState:UIControlStateNormal];
	[photo2 release];

	UIImage *photo3 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															   pathForResource:kDefaultPhotoSmall3
															   ofType:kPhotoType]];
	[defaultPhoto3 setBackgroundImage:photo3 forState:UIControlStateNormal];
	[photo3 release];

	UIImage *photo4 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															   pathForResource:kDefaultPhotoSmall4
															   ofType:kPhotoType]];
	[defaultPhoto4 setBackgroundImage:photo4 forState:UIControlStateNormal];
	[photo4 release];
}

- (void)selectPhotoWithPath:(NSString *)path type:(int)type
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:path
															  ofType:kPhotoType]];
	[photoController selectPhoto:photo type:type];
	[photo release];
	
	// Remove saved library photo (if exists)
	NSString *boardPhoto = [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:boardPhoto error:NULL];
	
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectPhoto1Action
{
	[self selectPhotoWithPath:kDefaultPhoto1 type:kDefaultPhoto1Type];
}

- (IBAction)selectPhoto2Action
{
	[self selectPhotoWithPath:kDefaultPhoto2 type:kDefaultPhoto2Type];
}

- (IBAction)selectPhoto3Action
{
	[self selectPhotoWithPath:kDefaultPhoto3 type:kDefaultPhoto3Type];
}

- (IBAction)selectPhoto4Action
{
	[self selectPhotoWithPath:kDefaultPhoto4 type:kDefaultPhoto4Type];
}

- (IBAction)cancelButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
