//
//  ViewController.m
//  NestedScroll
//
//  Created by qiyu on 2021/1/9.
//

#import "ViewController.h"
#import "TTableViewController.h"
#import "TTableView.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TTableView *rootTableView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, copy) NSArray<TTableViewController *> *childsTableVC;
@property (nonatomic, assign) BOOL rootTableViewCanScroll;
@property (nonatomic, assign) BOOL childTableViewCanScroll;

@end

#define mScreenHeight (UIScreen.mainScreen.bounds.size.height)
#define mScreenWidth (UIScreen.mainScreen.bounds.size.width)
#define mSafeAreaInsets (UIApplication.sharedApplication.windows.firstObject.safeAreaInsets)

static const CGFloat kHeaderViewHeight = 200.f;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // init
    self.rootTableViewCanScroll = YES;
    self.childTableViewCanScroll = NO;
    
    [self setupTableView];
}

- (void)setupTableView {
    CGRect frame = self.view.bounds;
    frame.origin.y = mSafeAreaInsets.top;
    frame.size.height = mScreenHeight - mSafeAreaInsets.top;
    self.rootTableView = [[TTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.rootTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.rootTableView.delegate = self;
    self.rootTableView.dataSource = self;
    self.rootTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.rootTableView];
    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.backgroundColor = UIColor.orangeColor;
    self.headerLabel.text = @"HeaderView";
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.frame = CGRectMake(0, 0, mScreenWidth, kHeaderViewHeight);
    self.rootTableView.tableHeaderView = self.headerLabel;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    if (!self.rootTableViewCanScroll) {
        scrollView.contentOffset = CGPointMake(0, kHeaderViewHeight);
        self.childTableViewCanScroll = YES;
    } else if (offset.y >= kHeaderViewHeight) {
        scrollView.contentOffset = CGPointMake(0, kHeaderViewHeight);
        self.childTableViewCanScroll = YES;
        self.rootTableViewCanScroll = NO;
    } else if (offset.y <= 0) {
        scrollView.contentOffset = CGPointZero;
        self.childTableViewCanScroll = YES;
    } else {
        self.childTableViewCanScroll = NO;
    }
}

- (void)childTableViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    if (!self.childTableViewCanScroll) {
        scrollView.contentOffset = CGPointZero;
    } else if (offset.y <= 0) {
        if (self.rootTableView.contentOffset.y <= 0) {
            self.childTableViewCanScroll = YES;
        }
        self.rootTableViewCanScroll = YES;
    } else {
        if (self.rootTableView.contentOffset.y > 0 && self.rootTableView.contentOffset.y < kHeaderViewHeight) {
            self.childTableViewCanScroll = NO;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mScreenHeight - mSafeAreaInsets.top - 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.categoryLabel = [[UILabel alloc] init];
    self.categoryLabel.text = @"CategoryView";
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.layer.borderWidth = 5;
    self.categoryLabel.layer.borderColor = UIColor.yellowColor.CGColor;
    return self.categoryLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    CGFloat cellHeight = mScreenHeight - mSafeAreaInsets.top - 50;
    UIScrollView *pageView = [[UIScrollView alloc] init]; /// 左右滑动可以是PageVC
    pageView.showsHorizontalScrollIndicator = NO;
    pageView.pagingEnabled = YES;
    [cell.contentView addSubview:pageView];
    pageView.frame = CGRectMake(0, 0, mScreenWidth, cellHeight);
    pageView.contentSize = CGSizeMake(mScreenWidth * 2, cellHeight);
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 2; ++i) {
        TTableViewController *tableVC = [[TTableViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        tableVC.didScrollTableViewBlock = ^(UIScrollView * _Nonnull scrollView) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf childTableViewDidScroll:scrollView];
        };
        [self addChildViewController:tableVC];
        [tableVC didMoveToParentViewController:self];
        [pageView addSubview:tableVC.view];
        CGRect frame = tableVC.view.frame;
        frame.size.height = cellHeight;
        frame.origin.x = i * mScreenWidth;
        tableVC.view.frame = frame;
        [array addObject:tableVC];
    }
    self.childsTableVC = array;
    return cell;
}

@end
