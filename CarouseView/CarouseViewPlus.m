//
//  CarouseViewPlus.m
//  CarouseView
//
//  Created by yxhe on 16/9/13.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import "CarouseViewPlus.h"

@interface CarouseViewPlus()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    NSInteger _pageCount;
    NSTimer *_kvTimer;
    TapCarouseViewBlock _tapBlock;
}

@end


@implementation CarouseViewPlus

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        // 添加scrollview和pagecontrol
        [self initScrollView];
        [self initPageControl];
        // 添加点击触摸事件
        [self initTapGesture];
    }
    return self;
}

#pragma mark - 初始化控件
- (void)initScrollView
{
    // 初始化尺寸
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    // 设置分页效果
    _scrollView.pagingEnabled = YES;
    // 水平滚动条隐藏
    _scrollView.showsHorizontalScrollIndicator = NO;
    // 设置到边的弹性隐藏
    _scrollView.bounces = NO;

    // 设置代理
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
}

- (void)initPageControl
{
    // 设置尺寸，坐标，注意纵坐标的起点
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
    // 设置当前页面索引
    _pageControl.currentPage = 0;
    // 设置未被选中时小圆点颜色
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    // 设置被选中时小圆点颜色
    _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
    // 设置能手动点小圆点条改变页数
    _pageControl.enabled = YES ;
    // 把导航条设置为半透明状态
    [_pageControl setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    // 设置分页控制器的事件
    [_pageControl addTarget:self action:@selector(pageControlTouched) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_pageControl];
}

- (void)initTapGesture
{
    // 点击事件
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(pageClick)];
    [self addGestureRecognizer:gesture];
}

#pragma mark - 分页点击回调
- (void)pageClick
{
    if (_tapBlock)
    {
        // 传入当前页面
        _tapBlock(_pageControl.currentPage);
    }
}

#pragma mark - 外部设置分页
- (void)setupSubviewPages:(NSArray *)pageViews withCallbackBlock:(TapCarouseViewBlock)block
{
    // 设置页数
    _pageCount = pageViews.count;
    // 设置滚动范围
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * _pageCount, CGRectGetHeight(self.frame));
    // 设置分页控件
    _pageControl.numberOfPages = _pageCount;
    // 设置回调
    _tapBlock = block;
    
    // 设置三个页面
    for (int i = 0; i < 3; i++)
    {
        UIView *page = pageViews[i];
        page.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        [_scrollView addSubview:page];
    }
}

#pragma mark - 定时器相关
- (void)startTimer
{
    _kvTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                target:self
                                              selector:@selector(changePageRight)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)stopTimer
{
    [_kvTimer invalidate];
    _kvTimer = nil;
}

#pragma mark - 定时器回调
- (void)changePageRight
{
    
}

- (void)changePageLeft
{
    
}

#pragma mark - pagecontrol事件
- (void)pageControlTouched
{
    
}

#pragma mark - scrollview滑动代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

@end
