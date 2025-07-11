//
//  PhotoController.m
//  Y-Tiles
//
//  Created by Chris Yunker on 12/15/08.
//  Copyright 2025 Chris Yunker. All rights reserved.
//

#import "PhotoController.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoController

@synthesize photoLibraryButton;
@synthesize photoDefaultButton;
@synthesize selectImageView;

- (id)initWithBoard:(Board *)aBoard
{
	if (self = [super init])
	{
		board = aBoard;
		
		// Use SF Symbol for modern appearance
		UIImage *photoImage = [UIImage systemImageNamed:@"photo"];
		if (!photoImage) {
			// Fallback to original image if SF Symbols not available
			photoImage = [UIImage imageNamed:@"Photo"];
		}
		[self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PhotoTitle", @"")
														   image:photoImage
															 tag:kTabBarPhotoTag]];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
}

- (void)didReceiveMemoryWarning
{
	ALog("didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setView:(UIView *)aView
{
	if (aView == nil)
	{
		DLog("Setting view to nil due to low memory");
		[self setPhotoDefaultButton:nil];
		[self setPhotoLibraryButton:nil];
		[self setSelectImageView:nil];
	}
	[super setView:aView];
}

- (void)loadView
{
	[super loadView];

	if (photoLibraryButton == nil)
	{
		// Create a custom photo library button with semi-opaque background
		UIButton *customLibraryButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[customLibraryButton addTarget:self action:@selector(photoLibraryButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		// Set button size
		customLibraryButton.frame = CGRectMake(0, 0, 110, 32);
		
		// Use modern UIButtonConfiguration with photo styling
		UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
		config.title = NSLocalizedString(@"PhotoLibraryButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
		config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
			NSMutableDictionary *attrs = [textAttributes mutableCopy];
			attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
			return attrs;
		};
		
		// Library button with same blue color as Start button
		config.background.backgroundColor = [UIColor systemBlueColor];
		config.background.cornerRadius = 10.0;
		
		customLibraryButton.configuration = config;
		
		photoLibraryButton = [[UIBarButtonItem alloc] initWithCustomView:customLibraryButton];
	}
	
	if (photoDefaultButton == nil)
	{
		// Create a custom default photo button with semi-opaque background
		UIButton *customDefaultButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[customDefaultButton addTarget:self action:@selector(photoDefaultButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		// Set button size
		customDefaultButton.frame = CGRectMake(0, 0, 110, 32);
		
		// Use modern UIButtonConfiguration with default photo styling
		UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
		config.title = NSLocalizedString(@"PhotoDefaultButton", @"");
		config.baseForegroundColor = [UIColor whiteColor];
		config.contentInsets = NSDirectionalEdgeInsetsMake(8, 16, 8, 16);
		config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
			NSMutableDictionary *attrs = [textAttributes mutableCopy];
			attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
			return attrs;
		};
		
		// Default photo button with same blue color as Start button
		config.background.backgroundColor = [UIColor systemBlueColor];
		config.background.cornerRadius = 10.0;
		
		customDefaultButton.configuration = config;
		
		photoDefaultButton = [[UIBarButtonItem alloc] initWithCustomView:customDefaultButton];
	}
	
	if (selectImageView == nil)
	{
		selectImageView = [[UIImageView alloc] initWithImage:[board photo]];
		[[self view] addSubview:selectImageView];
	}
    
	[[self navigationItem] setLeftBarButtonItem:photoDefaultButton];
	[[self navigationItem] setRightBarButtonItem:photoLibraryButton];
}

- (void)photoDefaultButtonAction
{
    PhotoDefaultController *pdc = [[PhotoDefaultController alloc] initWithPhotoController:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pdc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)photoLibraryButtonAction
{
	// Check to make sure pictures are available
    // NOTE: Not sure this can ever happen
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NoPhotos", @"")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
		return;
	}
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	[[picker navigationBar] setBarStyle:UIBarStyleBlack];
	[picker setAllowsEditing:NO];
	[picker setDelegate:self];
	[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController prefersStatusBarHidden];
}

- (void)selectPhoto:(UIImage *)photo type:(int)type
{
	if (type == kBoardPhotoInvalid)
	{
		// NOTE: Seems to be an iphone SDK bug when calling UIAlertView from
		// a UIImagePickerController delegate method.
		// This is an unlikely error so it's probably OK to silently error
		/*
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"InvalidPhoto", @"")
							  message:nil
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		*/
		
		return;
	}
	
	[board setPhoto:photo type:type];
	
	[selectImageView removeFromSuperview];
	[self setSelectImageView:[[UIImageView alloc] initWithImage:[board photo]]];
	[[self view] addSubview:selectImageView];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
	if (image == nil)
	{
		ALog("Invalid selected photo");
		[self selectPhoto:nil type:kBoardPhotoInvalid];
        [self dismissViewControllerAnimated:YES completion:nil];
		return;
	}
    
    UIImage *resizedImage = [self resizeImage:image size:board.frame.size];
	
	NSString *path = [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto];
	if (![UIImageJPEGRepresentation(resizedImage, 1) writeToFile:path atomically:YES])
	{
		ALog("PhotoController: Failed to write file [%@]", path);
	}
	
	[self selectPhoto:resizedImage type:kBoardPhotoType];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
