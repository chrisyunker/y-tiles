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

@synthesize photoPickerButton;
@synthesize photoDefaultButton;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{
		board = [aBoard retain];
		
		[self.tabBarItem
		 initWithTitle:NSLocalizedString(@"PhotoTitle", @"")
		 image:[UIImage imageNamed:@"Photo.png"]
		 tag:kTabBarPhotoTag];
	}
	return self;
}

- (void)dealloc
{
	DLog(@"dealloc");
	
	[photoPickerButton release];
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

- (void)loadView
{
	[super loadView];
	
	self.photoPickerButton = [[[UIBarButtonItem alloc]
							   initWithTitle:NSLocalizedString(@"PhotoPickerButton", @"")
							   style:UIBarButtonItemStyleDone
							   target:self
							   action:@selector(photoPickerButtonAction)] autorelease];

	self.photoDefaultButton = [[[UIBarButtonItem alloc]
								initWithTitle:NSLocalizedString(@"PhotoDefaultButton", @"")
								style:UIBarButtonItemStyleDone
								target:self
								action:@selector(photoDefaultButtonAction)] autorelease];
	
	self.navigationItem.leftBarButtonItem = photoDefaultButton;
	self.navigationItem.rightBarButtonItem = photoPickerButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");
	
	[super viewWillAppear:animated];
	
	selectImageView = [[UIImageView alloc] initWithImage:board.photo];
	[self.view addSubview:selectImageView];
}

- (void)viewDidDisappear:(BOOL)animated
{
	DLog(@"viewDidDisappear");
	
	[super viewDidDisappear:animated];
	
	[selectImageView removeFromSuperview];
	[selectImageView release];
}

- (void)photoDefaultButtonAction
{
	PhotoDefaultController *pdc = [[PhotoDefaultController alloc] initWithNibName:@"PhotoDefaultView" bundle:nil board:board];
	[self presentModalViewController:pdc animated:YES];
	[pdc release];
}

- (void)photoPickerButtonAction
{
	UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle:nil
						   delegate:self
						   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
						   destructiveButtonTitle:nil
						   otherButtonTitles:NSLocalizedString(@"TakePhoto", @""),
						   NSLocalizedString(@"ExistingPhoto", @""), nil];
	
	[menu setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	
	[menu showInView:[self.view window]];
	[menu release];
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
	UIGraphicsBeginImageContext(size);

	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}


# pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIImagePickerControllerSourceType sourceType;
			
	if (buttonIndex == 0)
	{		
		// Check to make sure camera is available
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		{		
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"NoCamera", @"")
								  message:nil
								  delegate:self
								  cancelButtonTitle:nil
								  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
			return;
		}
		
		sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else if (buttonIndex == 1)
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
		
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else
	{
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
	imagePicker.allowsImageEditing = NO;
	imagePicker.delegate = self;
	imagePicker.sourceType = sourceType;
	
	[self presentModalViewController:imagePicker animated:YES];
}


#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	UIImage *resizedImage = [self resizeImage:image size:board.frame.size];
	
	NSString *path = [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto];
	if (![UIImageJPEGRepresentation(resizedImage, 1) writeToFile:path atomically:YES])
	{
		ALog(@"PhotoController: Failed to write file [%@]", path);
	}
	
	[board setPhoto:resizedImage type:kBoardPhotoType];
	
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
}

@end
