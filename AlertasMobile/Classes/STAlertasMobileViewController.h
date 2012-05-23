//
//  STTableViewController.h
//  AlertasMobile
//
//  Created by Pedro on 25/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "EGORefreshTableHeaderView.h"
#import "SVProgressHUD.h"

@interface STAlertasMobileViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITabBarDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	
    EGORefreshTableHeaderView *_refreshHeaderView;
    UIActionSheet *callActionSheet;
    UIActionSheet *pictureActionSheet;
    BOOL newMedia;
}

@property (nonatomic, assign) IBOutlet UITabBarItem *openTabBarItem;
@property (nonatomic, assign) IBOutlet UITabBar *tabBar;
@property (retain, nonatomic) IBOutlet UIButton *TweetWithPictureButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *callButton;
@property (retain, nonatomic) IBOutlet UIViewController *rootViewController;

- (IBAction)placeCall:(UIBarButtonItem *)sender;
- (IBAction)tweetWithPicture:(UIButton *)sender;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
