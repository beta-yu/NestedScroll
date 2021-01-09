//
//  TTableView.m
//  NestedScroll
//
//  Created by qiyu on 2021/1/9.
//

#import "TTableView.h"

@implementation TTableView

/// 允许手势穿透
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
