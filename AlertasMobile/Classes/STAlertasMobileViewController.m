//
//  STTableViewController.m
//  AlertasMobile
//
//  Created by Pedro on 25/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STAlertasMobileViewController.h"
#import "STAlertasDataSource.h"

@implementation STAlertasMobileViewController

@synthesize openTabBarItem;
@synthesize tabBar;
@synthesize TweetWithPictureButton;
@synthesize callButton;
@synthesize rootViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    callActionSheet = nil;
    pictureActionSheet = nil;
        
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		refreshView.delegate = self;
        refreshView.backgroundColor = self.tableView.backgroundColor;
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:[STAlertasDataSource sharedAlertasDataSource]];
        [[STAlertasDataSource sharedAlertasDataSource] addObserver:self forKeyPath:@"open" options:NSKeyValueObservingOptionNew context:nil];
        [[STAlertasDataSource sharedAlertasDataSource] addObserver:self forKeyPath:@"lastRefresh" options:NSKeyValueObservingOptionNew context:nil];
        [[STAlertasDataSource sharedAlertasDataSource] addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
		[self.tableView addSubview:refreshView];
		_refreshHeaderView = refreshView;
		[refreshView release];
        [tabBar setSelectedItem:openTabBarItem];
	}
    
    [_refreshHeaderView refreshLastUpdatedDate];
    [self setupCallButton];
    //[self setupTweetWithPictureButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"open"] ) {
        NSInteger openCount =[[[STAlertasDataSource sharedAlertasDataSource] open] count];
        if ( openCount > 0 ) {
            [openTabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", openCount]];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:openCount];
        } else {
            [openTabBarItem setBadgeValue:nil];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    }
    
    if ([keyPath isEqualToString:@"lastRefresh"] ) {
        [self.tableView reloadData];
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    
    if ([keyPath isEqualToString:@"loading"] ) {
        BOOL loading = [[STAlertasDataSource sharedAlertasDataSource] loading];
        if ( loading ) {
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidBeginLoading:self.tableView];
        } else {
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        }
    }
}

#pragma mark Phone call methods

- (IBAction)placeCall:(UIBarButtonItem *)sender {
    if (callActionSheet == nil) {
        callActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Call", @"Call") 
                                                      delegate:self 
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:NSLocalizedString(@"FireHouse", @"FireHouse"), nil];

    }
    [callActionSheet showFromTabBar:tabBar];
}

- (void)setupCallButton {
    BOOL supportsPhoneCalls = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    callButton.enabled = supportsPhoneCalls;
}

#pragma mark -

#pragma mark Twitter methods

- (void)tweetWithImage:(UIImage *)image {
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = [[[TWTweetComposeViewController alloc] init] autorelease];
        [tweetSheet setInitialText:@"@bvcanas"];
        [tweetSheet addImage:image];
	    [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear networkIndicator:NO];
        [SVProgressHUD dismissWithError:NSLocalizedString(@"Can't send Tweets", @"Can't send Tweets")];
    }
}

- (void) setupTweetWithPictureButton {
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    [TweetWithPictureButton setEnabled:cameraAvailable];
}

#pragma mark -

#pragma mark Taking Picture

- (IBAction)tweetWithPicture:(UIButton *)sender {

    if ( pictureActionSheet == nil ) {
        pictureActionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                         delegate:self 
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                           destructiveButtonTitle:nil 
                                                otherButtonTitles:NSLocalizedString(@"Take Photo", @"Take Photo"), NSLocalizedString(@"Choose From Library", @"Choose From Library"), nil];
    }
    [pictureActionSheet showFromTabBar:tabBar];
}


- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        imagePickerController.sourceType = sourceType;
        imagePickerController.allowsEditing = NO;
        imagePickerController.delegate = self;
        [rootViewController presentModalViewController:imagePickerController animated:YES];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if ( picker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving...", @"Saving...") maskType:SVProgressHUDMaskTypeBlack networkIndicator:NO];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else {
            [self tweetWithImage:image];
        }
    }];
    
}

- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [SVProgressHUD dismissWithError:error.localizedDescription];
    } else {
        [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Saved", @"Saved")];
        [self tweetWithImage:image];
    }
}

#pragma mark -

#pragma mark ActionSheet Handler

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( actionSheet == callActionSheet ) {
        if ( buttonIndex == 0 ) {
            DLog(@"call");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://+351232671272"]];
        }
    }
    
    if ( actionSheet == pictureActionSheet ) {
        if ( buttonIndex == 0 ) { // Take Photo
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
        } else if ( buttonIndex == 1 ) { // Choose From Library
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}

#pragma mark -

#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	[[STAlertasDataSource sharedAlertasDataSource] reloadDataSourceWithTableViewController:self];
}

- (void)doneLoadingTableViewData{
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

#pragma mark -

#pragma mark UITabBarDelegate Methods
- (void)tabBar:(UITabBar *)tBar didSelectItem:(UITabBarItem *)item {
    [self.tableView setTag:[tabBar.items indexOfObject:item]];
    [self.tableView reloadData];
}

#pragma mark -

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return [[STAlertasDataSource sharedAlertasDataSource] loading];
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [[STAlertasDataSource sharedAlertasDataSource] lastRefresh];
	
}


#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[STAlertasDataSource sharedAlertasDataSource] removeObserver:self forKeyPath:@"open"];
    [[STAlertasDataSource sharedAlertasDataSource] removeObserver:self forKeyPath:@"lastRefresh"];
    [[STAlertasDataSource sharedAlertasDataSource] removeObserver:self forKeyPath:@"loading"];
	_refreshHeaderView = nil;
    [TweetWithPictureButton release];
    [callButton release];
    [callActionSheet release];
    [pictureActionSheet release];
    [rootViewController release];
    [super dealloc];
}


@end

