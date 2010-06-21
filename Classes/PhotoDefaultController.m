//
//  PhotoDefaultController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 2/26/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import "PhotoDefaultController.h"

@implementation PhotoDefaultController

@synthesize defaultPhoto1;
@synthesize defaultPhoto2;
@synthesize defaultPhoto3;
@synthesize defaultPhoto4;
@synthesize cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil board:(Board *)aBoard
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		board = [aBoard retain];
	}
	return self;
}

- (void)dealloc
{
	DLog(@"dealloc");
	
	[defaultPhoto1 release], defaultPhoto1 = nil;
	[defaultPhoto2 release], defaultPhoto2 = nil;
	[defaultPhoto3 release], defaultPhoto3 = nil;
	[defaultPhoto4 release], defaultPhoto4 = nil;
	[cancelButton release], cancelButton = nil;
	[board release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	ALog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)setView:(UIView *)aView
{
	DLog(@"setView [%@]", aView);
	
	if (aView == nil)
	{
		DLog(@"aView is nil");

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
	DLog(@"viewDidLoad");
	
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

- (IBAction)selectPhoto1Action
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:kDefaultPhoto1
															  ofType:kPhotoType]];
	[board setPhoto:photo type:kDefaultPhoto1Type];
	[photo release];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)selectPhoto2Action
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:kDefaultPhoto2
															  ofType:kPhotoType]];
	[board setPhoto:photo type:kDefaultPhoto2Type];
	[photo release];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)selectPhoto3Action
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:kDefaultPhoto3
															  ofType:kPhotoType]];
	[board setPhoto:photo type:kDefaultPhoto3Type];
	[photo release];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)selectPhoto4Action
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:kDefaultPhoto4
															  ofType:kPhotoType]];
	[board setPhoto:photo type:kDefaultPhoto4Type];
	[photo release];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)cancelButtonAction
{
	[self dismissModalViewControllerAnimated:YES];	
}

@end
