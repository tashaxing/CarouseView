//
//  ViewController.m
//  CarouseView
//
//  Created by yxhe on 16/9/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import "ViewController.h"
#import "CarouseView.h"

@interface ViewController ()<CarouseViewDataSource, CarouseViewDelegate>
{
    // 轮播图相关的数据
    NSArray *kvDataArray;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
    
    // 初始化一些数据
    kvDataArray = @[@"page 1", @"page 2", @"page3", @"page 4", @"page 5"];
    
    // 添加轮播图
    CarouseView *carouseView = [[CarouseView alloc] init];
    carouseView.frame = CGRectMake(0, 50, self.view.frame.size.width, 300);
    carouseView.datasource = self;
    carouseView.delegate = self;
    [self.view addSubview:carouseView];
}

#pragma mark - 轮播图代理
- (NSInteger)countOfCellForCarouseView:(CarouseView *)carouseView
{
    return kvDataArray.count;
}

- (UIView *)carouselView:(CarouseView *)carouselView cellAtIndex:(NSInteger)index
{
    // 填充view，可以是任意view
    UIView *cellView = [[UIView alloc] init];
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    cellView.backgroundColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
//    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg", (long)index]];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    [cellView addSubview:imageView];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 50)];
//    label.text = kvDataArray[index];
//    [cellView addSubview:label];
    
    return cellView;
}

- (void)carouseView:(CarouseView *)carouseView didSelectedAtIndex:(NSInteger)index
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"msg"
                                                        message:kvDataArray[index]
                                                       delegate:nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
