//
//  PhotoController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "PhotoController.h"
#import "Util.h"

@implementation PhotoController

@synthesize photoLibraryButton;
@synthesize photoDefaultButton;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{
		board = [aBoard retain];
		
		[self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PhotoTitle", @"")
														   image:[UIImage imageNamed:@"Photo.png"]
															 tag:kTabBarPhotoTag] autorelease]];
	}
	return self;
}

- (void)dealloc
{
	DLog(@"dealloc");
	
	[photoLibraryButton release];
	[photoDefaultButton release];
	[selectImageView release];
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
	if (aView == nil)
	{
		DLog(@"Setting view to nil due to low memory");
		
	}
	[super setView:aView];
}

- (void)loadView
{
	[super loadView];

	if (photoLibraryButton == nil)
	{
		photoLibraryButton = [[UIBarButtonItem alloc]
							 initWithTitle:NSLocalizedString(@"PhotoLibraryButton", @"")
							 style:UIBarButtonItemStyleDone
							 target:self
							 action:@selector(photoLibraryButtonAction)];
	}
	
	if (photoDefaultButton == nil)
	{
		photoDefaultButton = [[UIBarButtonItem alloc]
							  initWithTitle:NSLocalizedString(@"PhotoDefaultButton", @"")
							  style:UIBarButtonItemStyleDone
							  target:self
							  action:@selector(photoDefaultButtonAction)];
	}
	
	[[self navigationItem] setLeftBarButtonItem:photoDefaultButton];
	[[self navigationItem] setRightBarButtonItem:photoLibraryButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"-> viewWillAppear");
	[super viewWillAppear:animated];
	
	selectImageView = [[UIImageView alloc] initWithImage:[board photo]];
	[[self view] addSubview:selectImageView];
}

- (void)viewDidDisappear:(BOOL)animated
{
	DLog(@"<- viewDidDisappear");
	[super viewDidDisappear:animated];
	
	[selectImageView removeFromSuperview];
	[selectImageView release];
}

- (void)photoDefaultButtonAction
{
	PhotoDefaultController *pdc = [[PhotoDefaultController alloc] initWithNibName:@"PhotoDefaultView" bundle:nil photoController:self];
	[self presentModalViewController:pdc animated:YES];
	[pdc release];
}

- (void)photoLibraryButtonAction
{
	// Check to make sure pictures are available
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] &&
		![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
	{		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"NoPhotos", @"")
							  message:nil
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[[imagePicker navigationBar] setBarStyle:UIBarStyleBlackOpaque];
	[imagePicker setAllowsEditing:NO];
	[imagePicker setDelegate:self];
	[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	
	[self presentModalViewController:imagePicker animated:YES];
	
	//TODO: Why dont we release this?
	//[imagePicker release];
}

- (void)selectPhoto:(UIImage *)photo type:(int)type
{
	[board setPhoto:photo type:type];
	[[self tabBarController] setSelectedIndex:0];
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
	UIGraphicsBeginImageContext(size);

	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}


#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	DLog("size [%@]", board.frame);
	
	UIImage *resizedImage = [self resizeImage:image size:board.frame.size];
	
	NSString *path = [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto];
	if (![UIImageJPEGRepresentation(resizedImage, 1) writeToFile:path atomically:YES])
	{
		ALog(@"PhotoController: Failed to write file [%@]", path);
	}
	
	[board setPhoto:resizedImage type:kBoardPhotoType];
	
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
	
	[[self tabBarController] setSelectedIndex:0];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
}

@end
