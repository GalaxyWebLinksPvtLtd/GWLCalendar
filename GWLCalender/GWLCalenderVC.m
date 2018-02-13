//  Created by GalaxyWeblinks on 11/01/18.
//  Copyright © 2017 GalaxyWeblinks. All rights reserved.
//

#import "GWLCalenderVC.h"

#define HEIGHT_LOADING_VIEW 44

//========================== TimeCell ===========================
@interface TimeCell : UICollectionViewCell
@property ( nonatomic) UILabel *labelTime;
@end
@implementation TimeCell
@synthesize labelTime;
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        labelTime = [[UILabel alloc]initWithFrame:[self.contentView frame]];
        labelTime.layer.cornerRadius = 2.0;
        labelTime.layer.borderWidth = 0.5;
        [labelTime setFont:[UIFont systemFontOfSize:12.0]];
        labelTime.textAlignment = NSTextAlignmentCenter;
        labelTime.layer.borderColor = [UIColor colorWithRed:59.0/255.0 green:59.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor;
        labelTime.textColor = [UIColor blackColor];
        [self.contentView addSubview:labelTime];
    }
    return  self;
}
@end

//========================== DateCell ===========================
@interface DateCell : UITableViewCell
@property (strong, nonatomic)  UILabel  *labelDate;
@property (strong, nonatomic)  UILabel  *labelMonth;
@property (strong, nonatomic)  UIView   *viewSeprater;
@property (nonatomic)  CGFloat  cellHeight;
@end
@implementation DateCell
@synthesize labelDate,labelMonth,viewSeprater;

- (id)initWithStyle:(UITableViewCellStyle)style height:(CGFloat)hgt reuseIdentifier:(NSString*)reuseIdentifier {
    self.cellHeight = hgt;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        labelDate   = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.cellHeight, 20)];
        labelMonth  = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, self.cellHeight, 20)];
        viewSeprater  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0.5, 60)];
        
        [labelDate setFont:[UIFont boldSystemFontOfSize:12.0]];
        [labelMonth setFont:[UIFont boldSystemFontOfSize:12.0]];
        
        labelDate.textAlignment = NSTextAlignmentCenter;
        labelMonth.textAlignment = NSTextAlignmentCenter;
        
        [labelDate setBackgroundColor:[UIColor clearColor]];
        [labelMonth setBackgroundColor:[UIColor clearColor]];
        [viewSeprater setBackgroundColor:[UIColor lightGrayColor]];
        
        [self.contentView addSubview:labelDate];
        [self.contentView addSubview:labelMonth];
        [self.contentView addSubview:viewSeprater];
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }
    return self;
}
@end

@interface GWLCalenderVC () <UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UITableView *tableViewDate;
@property (nonatomic) UICollectionView *collectionViewTime;
@property (nonatomic) UIView *viewCalender;
@property (assign, nonatomic) CGFloat viewY;
@property (strong, nonatomic) NSMutableArray *arrayDate;
@property (strong, nonatomic) NSMutableArray *arrayTime;
@property (nonatomic) int priviousDates;
@property (nonatomic) int nextDates;
@property (nonatomic) int nextPrevious;
@property (nonatomic) int timeIntervel;
@property (assign, nonatomic) BOOL isScrollingTop;
@property (assign, nonatomic) BOOL isScrollingBottom;
@property (strong, nonatomic) UILabel * labelScheduleTime;
@property (strong, nonatomic) UILabel * labelMonth;
@property (nonatomic) int isTimeSelected;
@property (nonatomic) int isDateSelected;
@property (strong,nonatomic) NSDate* selectedDate;
@property (strong,nonatomic) NSDate* selectedTime;
@end

@implementation GWLCalenderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewSetUP];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 THis method use to render data view.
 */
- (void)viewSetUP {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    [components day]; //Day
    [components month];//Month
    [components year];//Year
    
    _priviousDates = 0;
    _nextDates = 0;
    _nextPrevious = (int)[components month];
    _isTimeSelected = -1;
    _isDateSelected = -1;
    self.arrayDate = [[NSMutableArray alloc]init];
    
    self.viewCalender = [[UIView alloc] init];
    self.viewCalender.backgroundColor = [UIColor whiteColor];
    self.viewCalender.layer.cornerRadius = 7.0;
    self.viewCalender.clipsToBounds = YES;
    [self.view addSubview:self.viewCalender];
    self.viewCalender.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20],
                                [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.viewCalender attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:20],
                                [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20]
                                ]
     ];
    [self makeDateTableView];
}

#pragma mark -
#pragma mark - Element placeing

- (void)makeDateTableView {

    UIView *viewTable = [[UIView alloc]init];
    viewTable.backgroundColor = [UIColor whiteColor];
    [self.viewCalender addSubview:viewTable];
    viewTable.translatesAutoresizingMaskIntoConstraints = NO;
    [viewTable addConstraint:[NSLayoutConstraint constraintWithItem:viewTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60]];
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewTable attribute:NSLayoutAttributeTop multiplier:1.0 constant:-70],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewTable attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewTable attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]]
     ];
    
    UIButton *previousMonthButton = [[UIButton alloc]init];
    previousMonthButton.backgroundColor = [UIColor clearColor];
    [previousMonthButton setImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
    [previousMonthButton addTarget:self action:@selector(actionOnPreviousMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCalender addSubview:previousMonthButton];
    previousMonthButton.translatesAutoresizingMaskIntoConstraints = NO;
    [previousMonthButton addConstraint:[NSLayoutConstraint constraintWithItem:previousMonthButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [previousMonthButton addConstraint:[NSLayoutConstraint constraintWithItem:previousMonthButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:viewTable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousMonthButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousMonthButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-20]]
     ];
    
    
    UIButton *nextMonthButton = [[UIButton alloc]init];
    nextMonthButton.backgroundColor = [UIColor clearColor];
    [nextMonthButton setImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
    [nextMonthButton addTarget:self action:@selector(actionOnNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCalender addSubview:nextMonthButton];
    nextMonthButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [nextMonthButton addConstraint:[NSLayoutConstraint constraintWithItem:nextMonthButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [nextMonthButton addConstraint:[NSLayoutConstraint constraintWithItem:nextMonthButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    
    
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:viewTable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nextMonthButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:nextMonthButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:20]]
     ];
    
    
    self.labelMonth = [[UILabel alloc] init];
    self.labelMonth.text = @"....";
    self.labelMonth.textColor = [UIColor blackColor];
    self.labelMonth.backgroundColor = [UIColor clearColor];
    [self.labelMonth setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    self.labelMonth.textAlignment = NSTextAlignmentCenter;
    [self.viewCalender addSubview:self.labelMonth];
    self.labelMonth.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.labelMonth addConstraint:[NSLayoutConstraint constraintWithItem:self.labelMonth attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    
    [self.viewCalender addConstraint:[NSLayoutConstraint constraintWithItem:nextMonthButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.labelMonth attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:nextMonthButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.labelMonth attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10],
                                        [NSLayoutConstraint constraintWithItem:previousMonthButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.labelMonth attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10]]
     ];
    
    int viewWidth = [UIApplication sharedApplication].keyWindow.frame.size.width-40;
    self.tableViewDate = [[UITableView alloc] init];
    self.tableViewDate.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
    self.tableViewDate.delegate = self;
    self.tableViewDate.dataSource = self;
    [viewTable addSubview:self.tableViewDate];
    self.tableViewDate.separatorColor = [UIColor whiteColor];
    self.tableViewDate.layer.borderWidth = 0.5;
    self.tableViewDate.layer.borderColor = [UIColor colorWithRed:59.0/255.0 green:59.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor;
    self.tableViewDate.backgroundColor = [UIColor clearColor];
    self.tableViewDate.showsVerticalScrollIndicator = NO;
    self.tableViewDate.frame = CGRectMake(0, 0, viewWidth,  60);
    
    self.labelScheduleTime = [[UILabel alloc] init];
    self.labelScheduleTime.text = @"../../....";
    self.labelScheduleTime.textColor = [UIColor whiteColor];
    [self.labelScheduleTime setFont:[UIFont boldSystemFontOfSize:15.0]];
    self.labelScheduleTime.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:59.0/255.0 blue:60.0/255.0 alpha:1.0];
    self.labelScheduleTime.textAlignment = NSTextAlignmentCenter;
    [self.viewCalender addSubview:self.labelScheduleTime];
    self.labelScheduleTime.translatesAutoresizingMaskIntoConstraints = NO;
    [self.labelScheduleTime addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScheduleTime attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:viewTable attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.labelScheduleTime attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.labelScheduleTime attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.labelScheduleTime attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]]
     ];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.viewCalender addSubview:bottomView];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [bottomView addConstraint:[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60]];
    
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]]
     ];
    
    
    UIButton *cancelButton = [[UIButton alloc]init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    cancelButton.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:126.0/255.0 blue:60.0/255.0 alpha:1.0];
    [cancelButton addTarget:self action:@selector(actionOnClose:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelButton];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *doneButton = [[UIButton alloc]init];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    doneButton.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:126.0/255.0 blue:60.0/255.0 alpha:1.0];
    [doneButton addTarget:self action:@selector(actionOnDone:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:doneButton];
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [bottomView addConstraints:@[
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cancelButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10],
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cancelButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10],
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cancelButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10],
                                 [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cancelButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10]
                                 ]
     ];
    
    
    
    
    [bottomView addConstraints:@[
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10],
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10],
                                 [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10],
                                 [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]
                                 ]
     ];
    
    
    CGFloat viewSubWidth = viewWidth - 50;
    float cellWidth = (viewSubWidth / 4.0);
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.minimumLineSpacing = 2;
    collectionViewFlowLayout.minimumInteritemSpacing = 2;
    collectionViewFlowLayout.itemSize = CGSizeMake(cellWidth, 40);
    self.collectionViewTime = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowLayout];
    self.collectionViewTime.delegate = self;
    self.collectionViewTime.dataSource = self;
    self.collectionViewTime.backgroundColor = [UIColor whiteColor];
    [self.viewCalender addSubview:self.collectionViewTime];
    self.collectionViewTime.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionViewTime registerClass:[TimeCell class] forCellWithReuseIdentifier:@"TimeCell"];
    
    [self.viewCalender addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:self.labelScheduleTime attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionViewTime attribute:NSLayoutAttributeTop multiplier:1.0 constant:-3],
                                        [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionViewTime attribute:NSLayoutAttributeBottom multiplier:1.0 constant:3],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.collectionViewTime attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10],
                                        [NSLayoutConstraint constraintWithItem:self.viewCalender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.collectionViewTime attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10]]
     ];
    
    [self getNextPreviousMonths:_nextPrevious];
}

-(void)initializeController:(UIViewController* )parent timeIntervel:(int)intervel completion:(dateTimeCallBack)callback {
    _block = callback;
    _timeIntervel = intervel;
    [parent.navigationController.view layoutIfNeeded];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self willMoveToParentViewController:parent.navigationController];
    [parent.navigationController addChildViewController:self];
    self.view.frame = [[UIApplication sharedApplication] keyWindow].frame;
    [parent.navigationController.view addSubview:self.view];
    [self didMoveToParentViewController:parent.navigationController];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSLayoutConstraint *bottomConstraint;NSLayoutConstraint *topConstraint;
    NSLayoutConstraint *leftConstraint;NSLayoutConstraint *rightConstraint;

    if (@available(iOS 11, *)) {
        
        bottomConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parent.navigationController.view.safeAreaLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0];
        
        
        topConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent.navigationController.view.safeAreaLayoutGuide
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0
                                                        constant:0];
        
        leftConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                       attribute:NSLayoutAttributeLeading
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent.navigationController.view.safeAreaLayoutGuide
                                                       attribute:NSLayoutAttributeLeading
                                                      multiplier:1.0
                                                        constant:0];
        
        rightConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:parent.navigationController.view.safeAreaLayoutGuide
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0];
        
        
    } else {
        
        bottomConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parent.navigationController.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0];
        
        
        topConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent.navigationController.view
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0
                                                        constant:0];
        
        
        
        leftConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:parent.navigationController.view
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0];
        
        rightConstraint   = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:parent.navigationController.view
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0
                                                          constant:0];
        
        
    }
    
    
    
    [parent.navigationController.view addConstraints:@[
                                topConstraint,
                                leftConstraint,
                                rightConstraint,
                                bottomConstraint
                                ]
     ];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    self.view.alpha = 0.0;
    [UIView animateWithDuration:.3 animations:^{
        self.view.alpha = 1.0;
        CGRect frameOfSheet = self.viewCalender.frame;
        frameOfSheet.origin.y = _viewY;
        self.viewCalender.frame = frameOfSheet;
    } completion:^(BOOL finished) {
        self.view.alpha = 1.0;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        [components day]; //Day
        [components month];//Month
        [components year];//Year
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[components day]-1 inSection:0];
        [self tableView:self.tableViewDate didSelectRowAtIndexPath:indexPath];
        [self.tableViewDate scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:YES];
    }];
}

-(void)removeSelfFromSuper {
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frameOfSheet = self.viewCalender.frame;
        frameOfSheet.origin.y = self.view.frame.size.height; // new x
        self.viewCalender.frame = frameOfSheet;
        self.view.alpha = 0.0;
    }completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
    }];
}

#pragma mark -
#pragma mark - UIButton action

- (void)actionOnClose:(id)sender {
    [self removeSelfFromSuper];
}

- (void)actionOnDone:(id)sender {
    [self removeSelfFromSuper];
    if(_block)
        _block(self.selectedTime != nil ? _selectedTime :_selectedDate);
}

- (void)actionOnPreviousMonth:(id)sender {
    self.nextPrevious =  self.nextPrevious - 1;
    [self getNextPreviousMonths:self.nextPrevious];
    [self getTime];
}

- (void)actionOnNextMonth:(id)sender {
    self.nextPrevious =  self.nextPrevious + 1;
    [self getNextPreviousMonths:self.nextPrevious];
    [self getTime];
}


#pragma mark -
#pragma mark - UITableView DataSource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  _viewCalender.frame.size.width/7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayDate.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell"];
    if (cell == nil)
        cell = [[DateCell alloc] initWithStyle:UITableViewCellStyleDefault height:_viewCalender.frame.size.width/7 reuseIdentifier:@"DateCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.labelDate.text = [[self.arrayDate objectAtIndex:indexPath.row] valueForKey:@"date"];
    cell.labelMonth.text = [[self.arrayDate objectAtIndex:indexPath.row] valueForKey:@"month"];
    NSDate *rowDate = [[self.arrayDate objectAtIndex:indexPath.row] valueForKey:@"nsdate"];
    if([self isTodayDate:rowDate] || [self isSelectedDate:rowDate]) {
        if([self isTodayDate:rowDate]) {
            cell.labelDate.textColor = [UIColor whiteColor];
            cell.labelMonth.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:100.0/255.0 blue:39.0/255.0 alpha:1.0];
        }
        if([self isSelectedDate:rowDate]) {
            cell.labelDate.textColor = [UIColor whiteColor];
            cell.labelMonth.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:126.0/255.0 blue:60.0/255.0 alpha:1.0];
        }
    }else {
        cell.labelDate.textColor = [UIColor blackColor];
        cell.labelMonth.textColor = [UIColor blackColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedDate = nil;
    [self.tableViewDate reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_isDateSelected inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    _isDateSelected = (int)indexPath.row ;
    _selectedTime = nil;
    _selectedDate = [[self.arrayDate objectAtIndex:_isDateSelected] valueForKey:@"nsdate"];
    self.labelScheduleTime.text = [self getSheduleDate:_selectedDate];
    [self getTime];
    [self.tableViewDate reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayTime.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TimeCell";
    TimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if([self isSelectedMonth:_selectedTime]) {
        NSDate *cellDate = [self isSelectedTime:[[self.arrayDate objectAtIndex:_isDateSelected] valueForKey:@"nsdate"] time:[self.arrayTime objectAtIndex:indexPath.row]];
        if([_selectedTime isEqualToDate:cellDate]) {
            cell.labelTime.textColor = [UIColor whiteColor];
            cell.labelTime.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:126.0/255.0 blue:60.0/255.0 alpha:1.0];
        }else {
            cell.labelTime.textColor = [UIColor blackColor];
            cell.labelTime.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        }
    }else {
        cell.labelTime.textColor = [UIColor blackColor];
        cell.labelTime.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    cell.labelTime.text =  [self.arrayTime objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _isTimeSelected = (int)indexPath.row ;
    _selectedTime = [self isSelectedTime:[[self.arrayDate objectAtIndex:_isDateSelected] valueForKey:@"nsdate"] time:[self.arrayTime objectAtIndex:_isTimeSelected]];
    self.labelScheduleTime.text = [self getSheduleDate:[[self.arrayDate objectAtIndex:_isDateSelected] valueForKey:@"nsdate"] time:[self.arrayTime objectAtIndex:_isTimeSelected]];
    [self.collectionViewTime reloadData];
}

#pragma mark -
#pragma mark - Scrolling

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if(scrollView == self.tableViewDate) {
//        if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height) {
//            self.isScrollingTop = YES;
//        }
//        if (scrollView.contentOffset.y < 0) {
//            self.isScrollingBottom = YES;
//        }
//    }
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//        if(self.isScrollingBottom) {
//            [self getNextDates];
//            self.isScrollingBottom = NO;
//        }
//
//        if(self.isScrollingTop) {
//            [self getPrevieousDates];
//            self.isScrollingTop = NO;
//        }
//}
//
//- (void)getNextDates {
//    NSLog(@"reach bottom");
//    _nextDates = _nextDates - 1;
//    NSLog(@"%d",_nextDates);
//}
//
//- (void)getPrevieousDates{
//    NSLog(@"reach top");
//    _priviousDates = _priviousDates + 1;
//    NSLog(@"%d",_priviousDates);
//}

#pragma mark -
#pragma mark - Dates

- (void)getMonthDates:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    comps=[calendar components:unitFlags fromDate:date];
    NSDate* weekstart=[calendar dateFromComponents:comps];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:weekstart];
    NSDateComponents* moveWeeks=[[NSDateComponents alloc] init];
    weekstart=[calendar dateByAddingComponents:moveWeeks toDate:weekstart options:0];
    self.arrayDate = [[NSMutableArray alloc] init];
    [self.tableViewDate reloadData];
    for (int i=0; i<range.length; i++) {
        NSDateComponents *compsToAdd = [[NSDateComponents alloc] init];
        compsToAdd.day=i;
        NSDate *nextDate = [calendar dateByAddingComponents:compsToAdd toDate:weekstart options:0];
        [self.arrayDate addObject:@{@"nsdate":nextDate,@"date":[self getdate:nextDate],@"month":[self getDay:nextDate]}];
    }
    [self.tableViewDate reloadData];
}

- (void)getNextPreviousMonths:(int)monthOffset {
    NSCalendar *cal         = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *comps = [cal components:unitFlags fromDate:[NSDate date]];
    comps.day = 1;
    comps.month  = monthOffset;
    NSDate *nextDate = [cal dateFromComponents:comps];
    self.labelMonth.text = [self getMonth:nextDate];
    [self getMonthDates:nextDate];
}

- (void)getTime {
    if(_selectedDate != nil) {
        self.arrayTime =[[NSMutableArray alloc] init];
        NSDate *myNewDate = _selectedDate;
        for (int i = 0 ; i < (1440/self.timeIntervel) ; i++) {
            NSDateComponents *components= [[NSDateComponents alloc] init];
            [components setMinute:self.timeIntervel];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            myNewDate=[calendar dateByAddingComponents:components toDate:myNewDate options:0];
            [self.arrayTime addObject:[self getTimeFromDate:myNewDate]];
        }
        [self.collectionViewTime reloadData];
    }
}

#pragma mark -
#pragma mark - Date Formatter

- (NSString*)getTimeFromDate:(NSDate*)dateTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:dateTime];
}


- (NSString *)getdate:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:dateDate];
}

- (NSString *)getDay:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"E"];
    return [formatter stringFromDate:dateDate];
}

- (NSString *)getMonth:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMMM/yyyy"];
    return [formatter stringFromDate:dateDate];
}

- (NSString *)getSheduleDate:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    return [formatter stringFromDate:dateDate];
}

- (BOOL)isTodayDate:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    if([[formatter stringFromDate:dateDate] isEqualToString:[formatter stringFromDate:[NSDate date]]])
        return YES;
    else
        return NO;
}

- (BOOL)isSelectedDate:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    if([[formatter stringFromDate:dateDate] isEqualToString:[formatter stringFromDate:_selectedDate]])
        return YES;
    else
        return NO;
}

- (BOOL)isSelectedMonth:(NSDate*)dateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMMM/yyyy"];
    if([self.labelMonth.text isEqualToString:[formatter stringFromDate:dateDate]])
        return YES;
    else
        return NO;
}

- (NSDate *)isSelectedTime:(NSDate*)dateDate time:(NSString *)timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[self getSheduleDate:dateDate],timeString]];
    return date;
}

- (NSString *)getSheduleDate:(NSDate*)dateDate time:(NSString *)timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[self getSheduleDate:dateDate],timeString]];
    [formatter setDateFormat:@"MM/dd/yyyy h:mm a"];
    return [formatter stringFromDate:date];
}

@end
