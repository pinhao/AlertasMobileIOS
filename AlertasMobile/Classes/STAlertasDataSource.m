//
//  STAlertasDataSource.m
//  AlertasMobile
//
//  Created by Pedro on 26/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STAlertasDataSource.h"

@implementation STAlertasDataSource

@synthesize open;
@synthesize closed;
@synthesize lastRefresh;
@synthesize loading;
@synthesize alertaCell;

+ (STAlertasDataSource *)sharedAlertasDataSource {
    static STAlertasDataSource *_sharedDataSource = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedDataSource = [[self alloc] init];
    });
    
    return _sharedDataSource;      
}

- (STAlertasDataSource *)init {
    self = [super init];
    if ( !self ) {
        return nil;
    }
    
    keys = [[NSArray alloc] initWithObjects:@"local", @"data", @"viaturas", @"bombeiros", @"descricao", nil];
    [self setLastRefresh:nil];
    [self setLoading:NO];
    
    return self;
    
}

- (void)reloadDataSourceWithTableViewController:(STAlertasMobileViewController *)tableViewController {
    if ( [self loading] )
        return;
    [[STBVCanasApi sharedClient] getPath:@"alertas.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id object){
        NSMutableArray *mutableOpen = [NSMutableArray array];
        NSMutableArray *mutableClosed = [NSMutableArray array];
        for ( NSDictionary *alert in object ) {
            BOOL isOpen = ![(NSNumber *)[alert objectForKey:@"fechado"] boolValue];
            if ( isOpen ) {
                [mutableOpen addObject:alert];
            } else {
                [mutableClosed addObject:alert];
            }
        }
        [self setOpen:[NSArray arrayWithArray:mutableOpen]];
        [self setClosed:[NSArray arrayWithArray:mutableClosed]];
        [self setLastRefresh:[NSDate date]];
        [self setLoading:NO];
        [tableViewController doneLoadingTableViewData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setLoading:NO];
        [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear networkIndicator:FALSE];
        [SVProgressHUD dismissWithError:error.localizedDescription];        
    }];
    [self setLoading:YES];
}

- (NSArray *)arrayForTableView:(UITableView *)tableView{
    if ( [tableView tag] == 0 ) {
        return [[open retain] autorelease];
    }
    return [[closed retain] autorelease];
}

- (id)valueAtTableView:(UITableView *)tableView WithKey:(NSString *)key AtSection:(NSInteger)section {
    NSArray *alerts = [self arrayForTableView:tableView];
    if ( alerts ) {        
        if ( section >= [alerts count] ) {
            return nil;
        }
        
        NSDictionary *alert = [alerts objectAtIndex:section];
        
        if ( alert == nil ) {
            return nil;
        }
        
        if ( [key isEqualToString:@"data"] ) {
            return [[NSString stringWithFormat:@"%@ %@", [alert valueForKey:key], [alert valueForKey:@"horaalerta"]] substringToIndex:16];
        }
        
        if ( [key isEqualToString:@"bombeiros"] ) {
            NSInteger numeroBombeiros = (NSInteger)[alert valueForKey:key];
            NSString *bombeiros = [NSString stringWithFormat:@"%@", numeroBombeiros];
            return bombeiros;
        }
        
        return [alert valueForKey:key];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#define PLACELABEL_TAG 1
#define TIMELABEL_TAG 2
#define VEHICLELABEL_TAG 3
#define PEOPLELABEL_TAG 4
#define DESCRIPTIONLABEL_TAG 5


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Alerta";
    UILabel *placeLabel, *timeLabel, *descriptionLabel, *peopleLabel, *vehicleLabel;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"STAlertasTableViewCell" owner:self options:nil];
        cell = alertaCell;
        self.alertaCell = nil;
    }
    
    placeLabel = (UILabel *)[cell viewWithTag:PLACELABEL_TAG];
    timeLabel = (UILabel *)[cell viewWithTag:TIMELABEL_TAG];
    peopleLabel = (UILabel *)[cell viewWithTag:PEOPLELABEL_TAG];
    vehicleLabel = (UILabel *)[cell viewWithTag:VEHICLELABEL_TAG];
    descriptionLabel = (UILabel *)[cell viewWithTag:DESCRIPTIONLABEL_TAG];
    
    [placeLabel setText:[self valueAtTableView:tableView WithKey:[keys objectAtIndex:0] AtSection:indexPath.section]];
    [timeLabel setText:[self valueAtTableView:tableView WithKey:[keys objectAtIndex:1] AtSection:indexPath.section]];
    [vehicleLabel setText:[self valueAtTableView:tableView WithKey:[keys objectAtIndex:2] AtSection:indexPath.section]];
    [peopleLabel setText:[self valueAtTableView:tableView WithKey:[keys objectAtIndex:3] AtSection:indexPath.section]];
    [descriptionLabel setText:[self valueAtTableView:tableView WithKey:[keys objectAtIndex:4] AtSection:indexPath.section]];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *alerts = [self arrayForTableView:tableView];
    if ( alerts ) {
        return [alerts count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
    NSArray *alerts = [self arrayForTableView:tableView];
    if ( section >= [alerts count] ) {
        return nil;
    }
    NSDictionary *alert = [alerts objectAtIndex:section];

    if ( alert ) {
        return [alert valueForKey:@"pedido"];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)dealloc {
    [keys release];
    keys = nil;
    [super dealloc];
}

@end
