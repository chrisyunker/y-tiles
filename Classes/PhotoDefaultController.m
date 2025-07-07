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
@synthesize navBar;

- (id)initWithPhotoController:(PhotoController *)aPhotoController
{
    if (self = [super init])
    {
		photoController = aPhotoController;
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
		[self setDefaultPhoto1:nil];
		[self setDefaultPhoto2:nil];
		[self setDefaultPhoto3:nil];
		[self setDefaultPhoto4:nil];
		[self setCancelButton:nil];
        [self setNavBar:nil];
	}
    
    [super setView:aView];
}

- (void)loadView
{
    [super loadView];

    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    int photoW = kDefPhotoButtonW;
    int photoH = kDefPhotoButtonH;
    if (screenRect.size.height - kNavBarHeight < 2*photoH)
    {
        photoH = (screenRect.size.height - kNavBarHeight - 30) / 2;
    }
    
    int hSpace = (int) (screenRect.size.width - 2 * photoW) / 3;
    int vSpace = (int) (screenRect.size.height - kNavBarHeight - 2 * photoH) / 3;
    
    if (cancelButton == nil)
    {
        cancelButton = [[UIBarButtonItem alloc]
                        initWithTitle:NSLocalizedString(@"DefaultCancelButton", @"")
                        style:UIBarButtonItemStyleDone
                        target:self
                        action:@selector(cancelButtonAction)];
    }
    if (navBar == nil)
    {
        navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kNavBarHeight)];
        navBar.translucent = NO;
        navBar.barTintColor = [UIColor colorWithRed:0.196f green:0.196f blue:0.196f alpha:1];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        navItem.rightBarButtonItem = cancelButton;
        navBar.items = @[ navItem ];
        
        [self.view addSubview:navBar];
    }
    if (defaultPhoto1 == nil)
    {
        UIImage *photo1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:kDefaultPhotoSmall1
                                                                   ofType:kPhotoType]];
        
        defaultPhoto1 = [UIButton buttonWithType: UIButtonTypeCustom];
        [defaultPhoto1 addTarget:self
                       action:@selector(selectPhoto1Action)
             forControlEvents:UIControlEventTouchUpInside];
        [defaultPhoto1 setFrame:CGRectMake(hSpace,
                                           (vSpace + kNavBarHeight),
                                           photoW,
                                           photoH)];
        [defaultPhoto1 setImage:photo1 forState:UIControlStateNormal];
        [[self view] addSubview:defaultPhoto1];
    }
    if (defaultPhoto2 == nil)
    {
        UIImage *photo2 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:kDefaultPhotoSmall2
                                                                   ofType:kPhotoType]];
        
        defaultPhoto2 = [UIButton buttonWithType: UIButtonTypeCustom];
        [defaultPhoto2 addTarget:self
                          action:@selector(selectPhoto2Action)
                forControlEvents:UIControlEventTouchUpInside];
        [defaultPhoto2 setFrame:CGRectMake((hSpace * 2 + photoW),
                                           (vSpace + kNavBarHeight),
                                           photoW,
                                           photoH)];
        [defaultPhoto2 setBackgroundImage:photo2 forState:UIControlStateNormal];
        [[self view] addSubview:defaultPhoto2];
    }
    if (defaultPhoto3 == nil)
    {
        UIImage *photo3 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:kDefaultPhotoSmall3
                                                                   ofType:kPhotoType]];
        
        defaultPhoto3 = [UIButton buttonWithType: UIButtonTypeCustom];
        [defaultPhoto3 addTarget:self
                          action:@selector(selectPhoto3Action)
                forControlEvents:UIControlEventTouchUpInside];
        [defaultPhoto3 setFrame:CGRectMake(hSpace,
                                           (vSpace * 2 + photoH + kNavBarHeight),
                                           photoW,
                                           photoH)];
        [defaultPhoto3 setBackgroundImage:photo3 forState:UIControlStateNormal];
        [[self view] addSubview:defaultPhoto3];
    }
    if (defaultPhoto4 == nil)
    {
        UIImage *photo4 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:kDefaultPhotoSmall4
                                                                   ofType:kPhotoType]];
        
        defaultPhoto4 = [UIButton buttonWithType: UIButtonTypeCustom];
        [defaultPhoto4 addTarget:self
                          action:@selector(selectPhoto4Action)
                forControlEvents:UIControlEventTouchUpInside];
        [defaultPhoto4 setFrame:CGRectMake((hSpace * 2 + photoW),
                                           (vSpace * 2 + photoH + kNavBarHeight),
                                           photoW,
                                           photoH)];
        [defaultPhoto4 setBackgroundImage:photo4 forState:UIControlStateNormal];
        [[self view] addSubview:defaultPhoto4];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController prefersStatusBarHidden];
}

- (void)selectPhotoWithPath:(NSString *)path type:(int)type
{
	UIImage *photo = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
															  pathForResource:path
															  ofType:kPhotoType]];
	[photoController selectPhoto:photo type:type];
	
	// Remove saved library photo (if exists)
	NSString *boardPhoto = [kDocumentsDir stringByAppendingPathComponent:kBoardPhoto];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:boardPhoto error:NULL];
	
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPhoto1Action
{
	[self selectPhotoWithPath:kDefaultPhoto1 type:kDefaultPhoto1Type];
}

- (void)selectPhoto2Action
{
	[self selectPhotoWithPath:kDefaultPhoto2 type:kDefaultPhoto2Type];
}

- (void)selectPhoto3Action
{
	[self selectPhotoWithPath:kDefaultPhoto3 type:kDefaultPhoto3Type];
}

- (void)selectPhoto4Action
{
	[self selectPhotoWithPath:kDefaultPhoto4 type:kDefaultPhoto4Type];
}

- (void)cancelButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
