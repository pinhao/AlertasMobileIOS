//
//  STAlertasDataSource.h
//  AlertasMobile
//
//  Created by Pedro on 26/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STAlertasMobileViewController.h"
#import "STBVCanasApi.h"
#import "SVProgressHUD.h"


@interface STAlertasDataSource : NSObject <UITableViewDataSource> {
    BOOL _reloading;
    NSArray *keys;
}

@property (atomic, retain) NSArray *open;
@property (atomic, retain) NSArray *closed;
@property (atomic, retain) NSDate *lastRefresh;
@property (atomic) BOOL loading;
@property (nonatomic, assign) IBOutlet UITableViewCell *alertaCell;

+ (STAlertasDataSource *)sharedAlertasDataSource;
- (void)reloadDataSourceWithTableViewController:(UITableViewController *)tableViewController;
- (id)valueAtTableView:(UITableView *)tableView WithKey:(NSString *)key AtSection:(NSInteger)section;
@end
