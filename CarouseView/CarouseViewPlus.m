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
    TapCarouseViewBlock _tapBlock;  // 内部block
    
    NSArray *_kvImageArray; // 存放展示图片集合
    
    NSInteger _prePageIndex; // 记录之前的page下标，用于pagecontrol小圆点事件
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
    // 设置图片集合
    _kvImageArray = pageViews;
    // 设置页数
    _pageCount = pageViews.count;
    // 设置滚动范围,只有三个页面
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame));
    // 设置分页控件
    _pageControl.numberOfPages = _pageCount;
    // 设置回调
    _tapBlock = block;
    
    // 设置三个页面
    for (int i = 0; i < 3; i++)
    {
        UIImageView *page = [[UIImageView alloc] init];
        page.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        // 保存一下tag方便后面索引，其实也可以写成成员变量
        page.tag = 1000 + i;
        [_scrollView addSubview:page];
    }
    
    // 设置初始展示图片
    UIImageView *leftPage = [_scrollView viewWithTag:1000];
    UIImageView *middlePage = [_scrollView viewWithTag:1001];
    UIImageView *rightPage = [_scrollView viewWithTag:1002];
    // 一开始要显示中间的第一张，所以左边放最后一张，右边放第二张
    leftPage.image = _kvImageArray.lastObject;
    middlePage.image = _kvImageArray.firstObject;
    rightPage.image = _kvImageArray[1];
    
    // 设置初始偏移量和索引
    _scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    _pageControl.currentPage = 0;
    _prePageIndex = 0;
    
    // 开启定时器
    [self startTimer];
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
    // 往右滑并且设置小圆点，永远都是滑到第三页
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:YES];
    [self resetPageIndex:YES];
}

- (void)changePageLeft
{
    // 往左滑，永远都是滑动到第一页
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self resetPageIndex:NO];
}

#pragma mark - 重新设置索引和页面图片
- (void)resetPageIndex:(BOOL)isRight
{
    if (isRight)
    {
        // 根据之前的page下标来修改
        if (_prePageIndex == _pageCount - 1)
        {
            // 到头了就回到第一个
            _pageControl.currentPage = 0;
        }
        else
        {
            // 这里用_prePageIndex来算，否则点击小圆点条会重复计算了
            _pageControl.currentPage = _prePageIndex + 1;
        }
    }
    else
    {
        if (_prePageIndex == 0)
        {
            _pageControl.currentPage = _pageCount - 1;
        }
        else
        {
            _pageControl.currentPage = _prePageIndex - 1;
        }
    }
    _prePageIndex = _pageControl.currentPage;
}

- (void)resetPageView
{
    // 每次滑动完了之后又重新设置当前显示的page时中间的page
    UIImageView *leftPage = [_scrollView viewWithTag:1000];
    UIImageView *middlePage = [_scrollView viewWithTag:1001];
    UIImageView *rightPage = [_scrollView viewWithTag:1002];
    
    if (_pageControl.currentPage == _pageCount - 1)
    {
        // n- 1 -> n -> 0
        leftPage.image = _kvImageArray[_pageControl.currentPage - 1];
        middlePage.image = _kvImageArray[_pageControl.currentPage];
        rightPage.image = _kvImageArray.firstObject;
        
    }
    else if (_pageControl.currentPage == 0)
    {
        // n -> 0 -> 1
        // 到尾部了，改成从头开始
        leftPage.image = _kvImageArray.lastObject;
        middlePage.image = _kvImageArray.firstObject;
        rightPage.image = _kvImageArray[1];
    }
    else
    {
        // x - 1 -> x -> x + 1
        leftPage.image = _kvImageArray[_pageControl.currentPage - 1];
        middlePage.image = _kvImageArray[_pageControl.currentPage];
        rightPage.image = _kvImageArray[_pageControl.currentPage + 1];
    }
    
    // 重新设置偏移量
    _scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
}

#pragma mark - pagecontrol事件
- (void)pageControlTouched
{
    [self stopTimer];
    
    NSInteger curPageIndex = _pageControl.currentPage;
    if (curPageIndex > _prePageIndex)
    {
        // 右滑
        [self changePageRight];
    }
    else
    {
        // 左滑
        [self changePageLeft];
    }
    
    [self startTimer];
}

#pragma mark - scrollview滑动代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 先停掉定时器
    [self stopTimer];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 手动拖拽滑动结束后
    if (scrollView.contentOffset.x > self.frame.size.width)
    {
        // 右滑
        [self resetPageIndex:YES];
    }
    else
    {
        // 左滑
        [self resetPageIndex:NO];
    }
    [self resetPageView];
    
    // 开启定时器
    [self startTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 自动滑动结束后重新设置图片
    [self resetPageView];
}

@end
