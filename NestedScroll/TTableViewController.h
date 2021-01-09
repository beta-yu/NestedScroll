//
//  TTableViewController.h
//  NestedScroll
//
//  Created by qiyu on 2021/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface TTableViewController : UIViewController

@property (nonatomic, copy) void (^didScrollTableViewBlock)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
