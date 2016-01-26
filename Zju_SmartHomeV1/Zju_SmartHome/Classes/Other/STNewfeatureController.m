//
//  STNewfeatureController.m
//  STWeibo
//
//  Created by 123 on 16/1/3.
//  Copyright © 2016年 HST. All rights reserved.
//

#import "STNewfeatureController.h"
#import "JYLoginViewController.h"

#define STNewfeatureImageCount 3

@interface STNewfeatureController ()<UIScrollViewDelegate>
@property(nonatomic,weak)UIPageControl *pageControl;
@end

@implementation STNewfeatureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.添加UIScrollView
    [self setupScrollView];
    
    //2.添加pageControl
    [self setupPageControl];
}

/**
 添加pageControl
 */
-(void)setupPageControl
{
    //1.添加
    UIPageControl *pageControl=[[UIPageControl alloc]init];
    pageControl.numberOfPages=STNewfeatureImageCount;
    pageControl.userInteractionEnabled=NO;
    
    CGFloat centerX=self.view.frame.size.width*0.5;
    CGFloat centerY=self.view.frame.size.height-30;
    pageControl.center=CGPointMake(centerX, centerY);
    pageControl.bounds=CGRectMake(0, 0, 100, 30);
    [self.view addSubview:pageControl];
    
    //2.设置圆点的颜色
    pageControl.currentPageIndicatorTintColor=[UIColor colorWithRed:253/255.0 green:98/255.0 blue:42/255.0 alpha:1];
    
    pageControl.pageIndicatorTintColor=[UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
    
    self.pageControl=pageControl;
}

/**
 添加UIScrollView
 */
-(void)setupScrollView
{
    //1.添加UIScrollView
    UIScrollView *scrollView=[[UIScrollView alloc]init];
    scrollView.frame=self.view.bounds;
    scrollView.delegate=self;
    [self.view addSubview:scrollView];
    
    //2.添加图片
    CGFloat imageW=scrollView.frame.size.width;
    CGFloat imageH=scrollView.frame.size.height;
    for (int index=0; index<STNewfeatureImageCount; index++) {
        UIImageView *imageView=[[UIImageView alloc]init];
        
        //设置图片
        NSString *name=[NSString stringWithFormat:@"%d",index+1];
        
        imageView.image=[UIImage imageNamed:name];
        
        //设置frame
        CGFloat imageX=index*imageW;
        imageView.frame=CGRectMake(imageX, 0, imageW, imageH);
        
        [scrollView addSubview:imageView];
        
        //在最后一个图片上面添加按钮
        if (index==STNewfeatureImageCount-1) {
            [self setupLastImageView:imageView];
        }
    }
    //3.设置滚动的内容尺寸
    scrollView.contentSize=CGSizeMake(imageW*STNewfeatureImageCount, 0);
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.pagingEnabled=YES;
    scrollView.bounces=NO;
}

/**
 添加内容到最后一个图片
 */
-(void)setupLastImageView:(UIImageView *)imageView
{
    //0.让imageView能跟用户交互
    imageView.userInteractionEnabled=YES;
    
    //1.添加开始按钮
    UIButton *startButton=[[UIButton alloc]init];
    
    [startButton setBackgroundImage:[UIImage imageNamed:@"kaiqi"] forState:UIControlStateNormal];
    //[startButton setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button_highlighted"] forState:UIControlStateHighlighted];
    //2.设置frame
    CGFloat width = imageView.frame.size.width;
    CGFloat centerX=width*0.5;
    CGFloat centerY=imageView.frame.size.height*0.8;
    startButton.center=CGPointMake(centerX, centerY);
    CGFloat orignalW=125;
    CGFloat orignalH=31;
    //进行适配6
    
    float ratio = 1.0f;
    
    if (width == 320.0)
    {
        //5或5s
    }
    else if (width == 375.0)
    {
        ratio = 375.0 / 320.0;
        
    }
    else if (width == 414.0)
    {
        ratio = 414.0 / 320.0;
    }
    CGFloat newW=orignalW*ratio;
    CGFloat newH=orignalH*ratio;
    startButton.bounds=(CGRect){CGPointZero,CGSizeMake(newW, newH)};
    [imageView addSubview:startButton];
    
    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    [imageView addSubview:startButton];
    
}

/**
 开始微博
 */
-(void)start
{
    //切换窗口的根控制器
    JYLoginViewController *loginVc=[[JYLoginViewController alloc]init];
    self.view.window.rootViewController=loginVc;
    loginVc.view.alpha=0.3;
    [UIView animateWithDuration:1.0 animations:^{
        loginVc.view.alpha=1.0;
    }completion:^(BOOL finished) {
        //显示状态栏
        [UIApplication sharedApplication].statusBarHidden=NO;
    }];
    
}
-(void)checkboxClick:(UIButton *)checkbox
{
    checkbox.selected=!checkbox.isSelected;
}
#pragma mark-scrollViewDelegate
/**
 只要UIScrollView滚动了，就会调用
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //1.取出水平方向上滚动的距离
    CGFloat offsetX=scrollView.contentOffset.x;
    
    //2.求出页码
    double pageDouble=offsetX/scrollView.frame.size.width;
    int pageInt=(int)(pageDouble+0.5);
    self.pageControl.currentPage=pageInt;
}
@end
