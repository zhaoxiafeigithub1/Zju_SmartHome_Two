//
//  DLLampControllYWModeViewController.m
//  Zju_SmartHome
//
//  Created by TooWalker on 15/12/1.
//  Copyright © 2015年 GJY. All rights reserved.
//

#import "DLLampControllYWModeViewController.h"
#import "ZQSlider.h"
#import "CYFFurnitureViewController.h"
#import "HttpRequest.h"
#import "PhotoViewController.h"
#import "MBProgressHUD+MJ.h"
#import "YSYWPatternViewController.h"
#import "STNewSceneController.h"
#import "STEditSceneController.h"
#import "STNewSceneView.h"
#import "JYPattern.h"
#import "JYPatternSqlite.h"

#define SCREEN_WIDTH self.view.frame.size.width
#define SCREEN_HEIGHT self.view.frame.size.height


@interface DLLampControllYWModeViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIPopoverControllerDelegate,STSaveNewSceneDelegate>
@property (nonatomic, weak) UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UILabel *LDValue; /**< light-dark-value */
@property (weak, nonatomic) IBOutlet UILabel *CWValue; /**< cold-warm-value */
@property (nonatomic, weak) UISlider *slider;
@property(nonatomic,strong)STNewSceneView *sceneView;


//YW控制
@property (weak, nonatomic) IBOutlet UIButton *ywAdjust;
//模式选择
@property (weak, nonatomic) IBOutlet UIButton *modeSelect;

@property(nonatomic,assign)int tag;
@property(nonatomic,assign)int switchTag;
//@property(nonatomic,assign)int sliderValueTemp;

@property(nonatomic,assign)int isPhoto;

//滑动条
@property (nonatomic, weak) UISlider *mySlider;
//存储滑动值的临时变量
@property(nonatomic,assign)int temp;
@property(nonatomic,strong)UISlider *mySlider2;

//有关照片取色的属性；
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (nonatomic,strong) UIAlertController *alert;
@property(nonatomic,strong)NSMutableArray *tempArray1;
//@property(nonatomic,assign)NSInteger count;
@property(nonatomic,strong)NSTimer *timer1;
@property(nonatomic,strong)NSTimer *timer2;
@property(nonatomic,strong)NSMutableArray *tempArray2;
- (IBAction)photoClick1:(id)sender;

@end

@implementation DLLampControllYWModeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
    NSLog(@"看看YW区域有没有过来:%@",self.area);
    self.tempArray1 = [NSMutableArray array];
    self.tempArray2 = [NSMutableArray array];
    
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:0.5  target:self selector:@selector(handleTimer1Action) userInfo:nil repeats:YES];
    [self.timer1 setFireDate:[NSDate distantFuture]];
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handleTimer2Action) userInfo:nil repeats:YES];
    [self.timer2 setFireDate:[NSDate distantFuture]];
  self.tag=1;
  self.switchTag = 1;
  //设置导航栏
  [self setNavigationBar];
  UIImageView *imgView = [[UIImageView alloc]init];
  imgView.tag = 10086;
  UIView *viewColorPickerPositionIndicator = [[UIView alloc]init];
  viewColorPickerPositionIndicator.tag = 10087;
  UIButton *btnPlay = [[UIButton alloc] init];
    
    UISlider *mySlider=[[UISlider alloc]init];
    self.mySlider=mySlider;
    UIColor *newColor=[UIColor colorWithRed:125/255.0f green:120/255.0f blue:86/255.0f alpha:1];
    self.mySlider.backgroundColor=newColor;
    // 设置UISlider的最小值和最大值
    self.mySlider.minimumValue = 0;
    self.mySlider.maximumValue = 100;
    
    // 为UISlider添加事件方法
    [self.mySlider addTarget:self action:@selector(handleYWSlider1Action:) forControlEvents:UIControlEventValueChanged];
    _mySlider.minimumTrackTintColor = [UIColor clearColor];
    _mySlider.maximumTrackTintColor = [UIColor clearColor];
    [_mySlider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    //设置圆角
    _mySlider.layer.cornerRadius=4;
    _mySlider.layer.masksToBounds=YES;
    [self.view addSubview:self.mySlider];
    
    UISlider *mySlider2=[[UISlider alloc]init];
    self.mySlider2=mySlider2;
    UIColor *newColor2=[UIColor colorWithRed:125/255.0f green:120/255.0f blue:86/255.0f alpha:1];
    self.mySlider2.backgroundColor=newColor2;
    // 设置UISlider的最小值和最大值
    self.mySlider2.minimumValue = 0;
    self.mySlider2.maximumValue = 100;
    
    // 为UISlider添加事件方法
    [self.mySlider2 addTarget:self action:@selector(handleYWSlider2Action:) forControlEvents:UIControlEventValueChanged];
    _mySlider2.minimumTrackTintColor = [UIColor clearColor];
    _mySlider2.maximumTrackTintColor = [UIColor clearColor];
    [_mySlider2 setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    //设置圆角
    _mySlider2.layer.cornerRadius=4;
    _mySlider2.layer.masksToBounds=YES;
    [self.view addSubview:self.mySlider2];
    _mySlider.value = 100;
    //KVO监听滑杆1和滑杆2的值得改变
    [_mySlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [_mySlider2 addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
  
  if (fabs(([[UIScreen mainScreen] bounds].size.height - 568)) < 1){
    // 5 & 5s & 5c
    imgView.image = [UIImage imageNamed:@"YWCircle_5"];
    viewColorPickerPositionIndicator.frame = CGRectMake(70, 70, 16, 16);
    viewColorPickerPositionIndicator.layer.cornerRadius = 8;
    viewColorPickerPositionIndicator.layer.borderWidth = 2;
    btnPlay.frame = CGRectMake(111, 111, 60, 60);
      self.mySlider.frame=CGRectMake(50, 440, 220, 8);
      self.mySlider2.frame=CGRectMake(50, 483, 220, 8);
    
  }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 667)) < 1) {
    // 6 & 6s
    imgView.image = [UIImage imageNamed:@"YWCircle_6"];
    viewColorPickerPositionIndicator.frame = CGRectMake(75, 75, 20, 20);
    viewColorPickerPositionIndicator.layer.cornerRadius = 10;
    viewColorPickerPositionIndicator.layer.borderWidth = 2;
    btnPlay.frame = CGRectMake(135, 135, 60, 60);
      self.mySlider.frame=CGRectMake(55, 516, 265, 9);
      self.mySlider2.frame=CGRectMake(55, 565, 265, 9);
    
  }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 736)) < 1){
    // 6p & 6sp
    imgView.image = [UIImage imageNamed:@"YWCircle_6p"];
    viewColorPickerPositionIndicator.frame = CGRectMake(80, 80, 24, 24);
    viewColorPickerPositionIndicator.layer.cornerRadius = 12;
    viewColorPickerPositionIndicator.layer.borderWidth = 2;
    btnPlay.frame = CGRectMake(150, 150, 60, 60);
      self.mySlider.frame=CGRectMake(60, 571, 295, 10);
      self.mySlider2.frame=CGRectMake(60, 624, 295, 10);
    
  }
  
  imgView.frame = CGRectMake(35.0f, 35.0f, imgView.image.size.width, imgView.image.size.height);
  
  
  imgView.userInteractionEnabled = YES;
  _imgView = imgView;
  
  viewColorPickerPositionIndicator.backgroundColor = [UIColor colorWithRed:0.996 green:1.000 blue:0.678 alpha:1.000];
  
  [btnPlay setBackgroundImage:[UIImage imageNamed:@"ct_icon_buttonbreak-off"] forState:UIControlStateNormal];
  
  [self.panelView addSubview:imgView];
  [self.panelView addSubview:viewColorPickerPositionIndicator];
  [self.panelView addSubview:btnPlay];
  
}
//timer1对应的事件
-(void)handleTimer1Action
{
    [HttpRequest sendYWBrightnessToServer:self.logic_id brightnessValue:[NSString stringWithFormat:@"%f",self.mySlider.value] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"发送的亮度值为%f",self.mySlider.value);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"检查网关"];
    }];
}
//timer2对应的事件
-(void)handleTimer2Action
{
    [HttpRequest sendYWWarmColdToServer:self.logic_id warmcoldValue:[NSString stringWithFormat:@"%f",self.mySlider2.value] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"发送的YW冷暖值为:%f",self.mySlider2.value);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
//视图消失时注销两个计时器
-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer1 invalidate];
    self.timer1 = nil;
    [self.timer2 invalidate];
    self.timer2 = nil;
    [self.mySlider removeObserver:self forKeyPath:@"value"];
    [self.mySlider2 removeObserver:self forKeyPath:@"value"];
    
}
//KVO监听到值得改变时对应的事件
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == _mySlider) {
        [self.timer1 setFireDate:[NSDate distantPast]];
        [self.timer2 setFireDate:[NSDate distantFuture]];
    }
    if (object == _mySlider2) {
        [self.timer2 setFireDate:[NSDate distantPast]];
        [self.timer1 setFireDate:[NSDate distantFuture]];
    }
    
}
//滑杆1对应的事件
-(void)handleYWSlider1Action:(UISlider *)sender
{
    
}
//滑杆2对应的事件
-(void)handleYWSlider2Action:(UISlider *)sender
{
    
}
//-(void)sliderValueChanged{
//    self.LDValue.text = [NSString stringWithFormat:@"%d", (int)self.slider.value ];
//    NSLog(@"＝＝＝%f",self.slider.value);
//    //在这里把亮暗值   (int)self.slider.value   传给服务器
//    if(fabsf(self.slider.value-self.sliderValueTemp)>9)
//    {
//        if(self.slider.value<=10)
//        {
//            self.slider.value=0;
//        }
//        if(self.slider.value>=90)
//        {
//            self.slider.value=100;
//        }
//        int value = (int)self.slider.value;
//        
//        [HttpRequest sendYWBrightnessToServer:self.logic_id brightnessValue:[NSString stringWithFormat:@"%d", value ] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            NSLog(@"YW亮暗返回成功：%@",result);
//            
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //NSLog(@"YW亮暗返回失败：%@",error);
//            [MBProgressHUD showError:@"请检查网关"];
//        }];
//    }
//  
//}
//-(void)sliderTouchUpInside
//{
//    NSLog(@"还原");
//    self.sliderValueTemp=0;
//}
/**
 *  判断点触位置，如果点触位置在颜色区域内的话，才返回点触的控件为UIImageView *imgView
 *  除此之外，点触位置落在小圆内部或者大圆外部，都返回nil
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  UIView *hitView = nil;
  
  UIImageView *imgView = (UIImageView *)[self.view viewWithTag:10086];
  NSLog(@"%@", NSStringFromCGRect(imgView.frame));
  BOOL pointInRound = [self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                                         bigRadius:imgView.frame.size.width * 0.48
                                       smallRadius:imgView.frame.size.width * 0.38
                                       targetPoint:point];
  if (pointInRound) {
    hitView = imgView;
  }
  return hitView;
}

/**
 *  判断点触位置是否落在了颜色区域内
 */
- (BOOL)touchPointInsideCircle:(CGPoint)center bigRadius:(CGFloat)bigRadius smallRadius:(CGFloat)smallRadius targetPoint:(CGPoint)point
{
  
  CGFloat dist = sqrtf((point.x - center.x) * (point.x - center.x) +
                       (point.y - center.y) * (point.y - center.y));
  if (dist >= bigRadius || dist <= smallRadius){
    return NO;
  }else{
    return YES;
  }
}

/**
 *  开始点击的方法
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  UITouch *touch = touches.anyObject;
  
  CGPoint touchLocation = [touch locationInView:self.imgView];
  //UIView *hitView = nil;
  
  UIImageView *imgView = (UIImageView *)[self.view viewWithTag:10086];
  //  NSLog(@"%@", NSStringFromCGRect(imgView.frame));
  BOOL pointInRound = [self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                                         bigRadius:imgView.frame.size.width * 0.48
                                       smallRadius:imgView.frame.size.width * 0.38
                                       targetPoint:touchLocation];
  if (pointInRound) {
    
    //    UIImageView *colorImageView = (UIImageView *)[self.view viewWithTag:10086];
    UIView *viewColorPickerPositionIndicator = (UIView *)[self.view viewWithTag:10087];
    //    UITouch *touch = touches.anyObject;
    //
    //    CGPoint touchLocation = [touch locationInView:self.imgView];
    UIColor *positionColor = [self getPixelColorAtLocation:touchLocation];
    const CGFloat *components = CGColorGetComponents(positionColor.CGColor);
    
    if ([self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                           bigRadius:imgView.frame.size.width * 0.48
                         smallRadius:imgView.frame.size.width * 0.38        //0.39
                         targetPoint:touchLocation]) {
      
      viewColorPickerPositionIndicator.center = CGPointMake(touchLocation.x + 35, touchLocation.y + 35);
      viewColorPickerPositionIndicator.backgroundColor = [self getPixelColorAtLocation:touchLocation];
      
      
      int cwValue = (int)(touchLocation.y / 2.5) - 2;
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 480)) < 1) {
        // 4 & 4s
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
      }
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 568)) < 1){
        // 5 & 5s & 5c
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
        
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 667)) < 1) {
        // 6 & 6s
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue += 1;
        }
        
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 736)) < 1){
        // 6p & 6sp
        
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue = (float)(cwValue) / 111 * 100;
        }
      }
      
      self.CWValue.text = [NSString stringWithFormat:@"%d", cwValue];
        NSLog(@"我看看这到底是啥: %@",self.CWValue.text);
      //在这里把cwValuevalue值传给服务器
      cwValue = 100 - cwValue;
      [HttpRequest sendYWWarmColdToServer:self.logic_id warmcoldValue:[NSString stringWithFormat:@"%d", cwValue] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"YW冷暖返回成功：%@",result);
        
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"YW冷暖返回失败：%@",error);
      }];
      
    }
  }
}

/**
 *  手指在屏幕上移动的方法
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = touches.anyObject;
  
  CGPoint touchLocation = [touch locationInView:self.imgView];
  //UIView *hitView = nil;
  
  UIImageView *imgView = (UIImageView *)[self.view viewWithTag:10086];
  //  NSLog(@"%@", NSStringFromCGRect(imgView.frame));
  BOOL pointInRound = [self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                                         bigRadius:imgView.frame.size.width * 0.48
                                       smallRadius:imgView.frame.size.width * 0.38
                                       targetPoint:touchLocation];
  if (pointInRound) {
    //    UIImageView *colorImageView = (UIImageView *)[self.view viewWithTag:10086];
    UIView *viewColorPickerPositionIndicator = (UIView *)[self.view viewWithTag:10087];
    UITouch *touch = touches.anyObject;
    
    CGPoint touchLocation = [touch locationInView:self.imgView];
    UIColor *positionColor = [self getPixelColorAtLocation:touchLocation];
    const CGFloat *components = CGColorGetComponents(positionColor.CGColor);
    
    if ([self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                           bigRadius:imgView.frame.size.width * 0.48
                         smallRadius:imgView.frame.size.width * 0.38        //0.39
                         targetPoint:touchLocation]) {
    
      //        viewColorPickerPositionIndicator.center = touchLocation;
      viewColorPickerPositionIndicator.center = CGPointMake(touchLocation.x + 35, touchLocation.y + 35);
      viewColorPickerPositionIndicator.backgroundColor = [self getPixelColorAtLocation:touchLocation];
        self.mySlider.backgroundColor=[self getPixelColorAtLocation:touchLocation];
        self.mySlider2.backgroundColor=[self getPixelColorAtLocation:touchLocation];
      
      
      int cwValue = (int)(touchLocation.y / 2.5) - 2;
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 480)) < 1) {
        // 4 & 4s
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
      }
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 568)) < 1){
        // 5 & 5s & 5c
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 667)) < 1) {
        // 6 & 6s
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue += 1;
        }
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 736)) < 1){
        // 6p & 6sp
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue = (float)(cwValue) / 111 * 100;
        }
      }
      self.CWValue.text = [NSString stringWithFormat:@"%d", cwValue];
      
      int i, j;
      if ((i = arc4random() % 2)) {
        if ((j = arc4random() % 2)) {
          //在这里把cwValuevalue值传给服务器
          
          cwValue = 100 - cwValue;
          [HttpRequest sendYWWarmColdToServer:self.logic_id warmcoldValue:[NSString stringWithFormat:@"%d", cwValue] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"YW冷暖返回成功：%@",result);
            
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"YW冷暖返回失败：%@",error);
          }];
        }
      }
    }}
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
  UITouch *touch = touches.anyObject;
  
  CGPoint touchLocation = [touch locationInView:self.imgView];
 // UIView *hitView = nil;
  
  UIImageView *imgView = (UIImageView *)[self.view viewWithTag:10086];
  //  NSLog(@"%@", NSStringFromCGRect(imgView.frame));
  BOOL pointInRound = [self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                                         bigRadius:imgView.frame.size.width * 0.48
                                       smallRadius:imgView.frame.size.width * 0.38
                                       targetPoint:touchLocation];
  if (pointInRound) {
    
    //    UIImageView *colorImageView = (UIImageView *)[self.view viewWithTag:10086];
    UIView *viewColorPickerPositionIndicator = (UIView *)[self.view viewWithTag:10087];
    //    UITouch *touch = touches.anyObject;
    //
    //    CGPoint touchLocation = [touch locationInView:self.imgView];
    UIColor *positionColor = [self getPixelColorAtLocation:touchLocation];
    const CGFloat *components = CGColorGetComponents(positionColor.CGColor);
    
    if ([self touchPointInsideCircle:CGPointMake(imgView.frame.size.width / 2, imgView.frame.size.height / 2)
                           bigRadius:imgView.frame.size.width * 0.48
                         smallRadius:imgView.frame.size.width * 0.38        //0.39
                         targetPoint:touchLocation]) {
      
      //        viewColorPickerPositionIndicator.center = touchLocation;
      viewColorPickerPositionIndicator.center = CGPointMake(touchLocation.x + 35, touchLocation.y + 35);
      viewColorPickerPositionIndicator.backgroundColor = [self getPixelColorAtLocation:touchLocation];
        self.mySlider.backgroundColor=[self getPixelColorAtLocation:touchLocation];
        self.mySlider2.backgroundColor=[self getPixelColorAtLocation:touchLocation];
      
      int cwValue = (int)(touchLocation.y / 2.5) - 2;
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 480)) < 1) {
        // 4 & 4s
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
      }
      if (fabs(([[UIScreen mainScreen] bounds].size.height - 568)) < 1){
        // 5 & 5s & 5c
        if (cwValue < 63) {
          cwValue = cwValue + 1;
        }else{
          cwValue = (float)(cwValue) / 81 * 100;
        }
        
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 667)) < 1) {
        // 6 & 6s
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue += 1;
        }
        
      }else if (fabs(([[UIScreen mainScreen] bounds].size.height - 736)) < 1){
        // 6p & 6sp
        
        if (cwValue < 63) {
          cwValue = cwValue;
        }else{
          cwValue = (float)(cwValue) / 111 * 100;
        }
      }
      
      self.CWValue.text = [NSString stringWithFormat:@"%d", cwValue];
      //在这里把cwValuevalue值传给服务器
        cwValue = 100 - cwValue;
      [HttpRequest sendYWWarmColdToServer:self.logic_id warmcoldValue:[NSString stringWithFormat:@"%d", cwValue] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"YW冷暖返回成功：%@ 实际传送值: %@",result,[NSString stringWithFormat:@"%d", cwValue]);
        
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"YW冷暖返回失败：%@",error);
      }];
      
    }
  }
}


//*****************************获取屏幕点触位置的RGB值的方法************************************//
- (UIColor *) getPixelColorAtLocation:(CGPoint)point {
  UIColor* color = nil;
  
  UIImageView *colorImageView = (UIImageView *)[self.view viewWithTag:10086];
  
  CGImageRef inImage = colorImageView.image.CGImage;
  
  CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
  if (cgctx == NULL) {
    return nil;
  }
  size_t w = CGImageGetWidth(inImage);
  size_t h = CGImageGetHeight(inImage);
  CGRect rect = {{0,0},{w,h}};
  
  CGContextDrawImage(cgctx, rect, inImage);
  
  unsigned char* data = CGBitmapContextGetData (cgctx);
  if (data != NULL) {
    int offset = 4*((w*round(point.y))+round(point.x));
    int alpha =  data[offset];
    int red = data[offset+1];
    int green = data[offset+2];
    int blue = data[offset+3];
    
    color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
  }
  
  CGContextRelease(cgctx);
  
  if (data) { free(data); }
  return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
  
  CGContextRef    context = NULL;
  CGColorSpaceRef colorSpace;
  void *          bitmapData;
  int             bitmapByteCount;
  int             bitmapBytesPerRow;
  
  size_t pixelsWide = CGImageGetWidth(inImage);
  size_t pixelsHigh = CGImageGetHeight(inImage);
  
  bitmapBytesPerRow   = (int)(pixelsWide * 4);
  bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
  
  colorSpace = CGColorSpaceCreateDeviceRGB();
  
  if (colorSpace == NULL)
  {
    fprintf(stderr, "Error allocating color space\n");
    return NULL;
  }
  
  bitmapData = malloc( bitmapByteCount );
  if (bitmapData == NULL)
  {
    fprintf (stderr, "Memory not allocated!");
    CGColorSpaceRelease( colorSpace );
    return NULL;
  }
  context = CGBitmapContextCreate (bitmapData,
                                   pixelsWide,
                                   pixelsHigh,
                                   8,
                                   bitmapBytesPerRow,
                                   colorSpace,
                                   kCGImageAlphaPremultipliedFirst);
  if (context == NULL)
  {
    free (bitmapData);
    fprintf (stderr, "Context not created!");
  }
  CGColorSpaceRelease( colorSpace );
  return context;
}

//****************************************结束
- (void)leftBtnClicked
{
  if(self.sceneTag==41)
  {
      for (UIViewController *controller in self.navigationController.viewControllers)
      {

         if ([controller isKindOfClass:[STNewSceneController class]])
         {
           [self.navigationController popToViewController:controller animated:YES];
         }
      }
  }
  else if(self.sceneTag==411)
  {
      for (UIViewController *controller in self.navigationController.viewControllers)
      {
          
          if ([controller isKindOfClass:[STEditSceneController class]])
          {
              [self.navigationController popToViewController:controller animated:YES];
          }
      }
  }
  else
  {
      for (UIViewController *controller in self.navigationController.viewControllers)
      {
          if ([controller isKindOfClass:[YSYWPatternViewController class]])
          {
              
              [self.navigationController popToViewController:controller animated:YES];
              
          }
          
      }
  }
}

//保存按钮
-(void)rightBtnClicked
{
    NSString *string=[NSString stringWithFormat:@"%d",100-[self.CWValue.text intValue]];
    NSLog(@"===%@ %@",self.logic_id,string);
    NSLog(@"看看标志是啥:%d",self.sceneTag);
    
    //说明是从新建场景界面过来的
    if(self.sceneTag==41)
    {
        if([self.delegate respondsToSelector:@selector(backParamYW:andParam2:andParam3:andLogic_Id:andType:)])
        {
            [self.delegate backParamYW:string andParam2:@"0" andParam3:@"0" andLogic_Id:self.logic_id andType:self.type];
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                
                if ([controller isKindOfClass:[STNewSceneController class]]) {
                    
                    [self.navigationController popToViewController:controller animated:YES];
                    
                }
                
            }
        }
    }
    //说明是从编辑场景界面过来的
    else if(self.sceneTag==411)
    {
        NSLog(@"这里应该要将YW数值传递回编辑场景界面了");
        if([self.delegate respondsToSelector:@selector(backParamYW:andParam2:andParam3:andLogic_Id:andType:)])
        {
            [self.delegate backParamYW:string andParam2:@"0" andParam3:@"0" andLogic_Id:self.logic_id andType:self.type];
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                
                if ([controller isKindOfClass:[STEditSceneController class]]) {
                    
                    [self.navigationController popToViewController:controller animated:YES];
                    
                }
                
            }
        }
    }
    else
    {
        NSLog(@"保存为YW灯的新模式");
//        NSString *string=[NSString stringWithFormat:@"%d",100-[self.CWValue.text intValue]];
//        NSLog(@"===%@ %@",self.logic_id,string);
        
        STNewSceneView *stView=[STNewSceneView saveNewSceneView];
        stView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        [UIView animateWithDuration:0.5 animations:^{
            [stView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            
        }completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden=YES;
        }];
        
        stView.delegate=self;
        self.sceneView=stView;
        [self.view addSubview:stView];
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
}
-(void)cancelSaveScene
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.sceneView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    } completion:^(BOOL finished) {
        [self.sceneView removeFromSuperview];
    }];
    self.navigationItem.rightBarButtonItem.enabled=YES;
    self.navigationController.navigationBar.hidden=NO;
}
-(void)noSave
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.sceneView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    } completion:^(BOOL finished) {
        [self.sceneView removeFromSuperview];
    }];
    self.navigationItem.rightBarButtonItem.enabled=YES;
    self.navigationController.navigationBar.hidden=NO;
}
-(void)saveNewScene:(NSString *)sceneName
{
    NSLog(@"WWW :%@",sceneName);
    //self.navigationController.navigationBar.hidden=NO;
    self.navigationItem.rightBarButtonItem.enabled=YES;
    NSLog(@"－－－－%@",sceneName);
     NSString *string=[NSString stringWithFormat:@"%d",100-[self.CWValue.text intValue]];
    
    //1.创建请求管理对象
    AFHTTPRequestOperationManager *mgr=[AFHTTPRequestOperationManager manager];
    
    //2.说明服务器返回的是json参数
    mgr.responseSerializer=[AFJSONResponseSerializer serializer];
    
    //3.封装请求参数
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"is_app"]=@"1";
    params[@"sceneconfig.room_name"]=self.area;
    params[@"sceneconfig.tag"]=@"0";
    params[@"sceneconfig.equipment_logic_id"]=self.logic_id;
    params[@"sceneconfig.scene_name"]=sceneName;
    params[@"sceneconfig.param1"]=string;
    params[@"sceneconfig.param2"]=@"0";
    params[@"sceneconfig.param3"]=@"0";
    params[@"sceneconfig.image"]=@"rouhe_bg";
    NSLog(@"---%@ %@ %@ %@  ",self.area,self.logic_id, sceneName,string);
    
    //4.发送请求
    [mgr POST:@"http://60.12.220.16:8888/paladin/Sceneconfig/create" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"看看YW增加模式返回的数据是啥呢？%@",responseObject);
         self.navigationController.navigationBar.hidden=NO;
         if([responseObject[@"code"] isEqualToString:@"0"])
         {
             JYPatternSqlite *jySqlite=[[JYPatternSqlite alloc]init];
             jySqlite.patterns=[[NSMutableArray alloc]init];
             
             //打开数据库
             [jySqlite openDB];
             
             [jySqlite insertRecordIntoTableName:self.tableName withField1:@"logic_id" field1Value:self.logic_id andField2:@"name" field2Value:sceneName andField3:@"bkgName" field3Value:@"rouhe_bg" andField4:@"param1" field4Value:string andField5:@"param2" field5Value:@"0" andField6:@"param3" field6Value:@"0"];
             
             for (UIViewController *controller in self.navigationController.viewControllers)
             {
                 if ([controller isKindOfClass:[YSYWPatternViewController class]])
                 {
                     YSYWPatternViewController *vc=(YSYWPatternViewController *)controller;
                     vc.tag_Back=2;
                     [self.navigationController popToViewController:controller animated:YES];
                 }
             }
         }
         else
         {
             [MBProgressHUD showError:@"增加模式失败"];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD showError:@"增加模式失败,请检查服务器"];
     }];
}

-(void)setNavigationBar
{
    UIButton *leftButton=[[UIButton alloc]init];
    [leftButton setImage:[UIImage imageNamed:@"ct_icon_leftbutton"] forState:UIControlStateNormal];
    leftButton.frame=CGRectMake(0, 0, 25, 25);
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftButton addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
//    UIButton *rightButton=[[UIButton alloc]init];
//    [rightButton setImage:[UIImage imageNamed:@"ct_icon_switch"] forState:UIControlStateNormal];
//    rightButton.frame=CGRectMake(0, 0, 30, 30);
//    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(-4, 6, 4, -10)];
//    [rightButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem=rightItem;
    
    //保存按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(rightBtnClicked)];
    self.navigationItem.rightBarButtonItem=rightItem;
    
    
    UILabel *titleView=[[UILabel alloc]init];
    [titleView setText:@"YW灯"];
    titleView.frame=CGRectMake(0, 0, 100, 16);
    titleView.font=[UIFont systemFontOfSize:16];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=titleView;
}

-(void)ywClick
{
    NSLog(@"实际上是YW灯");
}
- (IBAction)photoClick1:(id)sender
{
    self.isPhoto=1;
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.delegate = self;
    //这里可以设置是否允许编辑图片；
    imagePicker.allowsEditing = false;
    
    
    /**
     *  应该在这里让用户选择是打开摄像头还是图库；
     */
    //初始化提示框；
    self.alert = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:  UIAlertControllerStyleActionSheet];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //创建UIPopoverController对象前先检查当前设备是不是ipad
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.imagePickerPopover.delegate = self;
            [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];
        }
        else{
            
            //跳到ShowPhoto页面；
            PhotoViewController *showPhoto = [[PhotoViewController alloc] init];
            showPhoto.openType = UIImagePickerControllerSourceTypeCamera;//从照相机打开；
            showPhoto.logic_id = self.logic_id;
            [self.navigationController pushViewController:showPhoto animated:true];
        }
    }]];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        //创建UIPopoverController对象前先检查当前设备是不是ipad
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.imagePickerPopover.delegate = self;
            [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];
        }
        else{
            //跳到ShowPhoto页面；
            PhotoViewController *showPhoto = [[PhotoViewController alloc] init];
            showPhoto.openType = UIImagePickerControllerSourceTypePhotoLibrary;//从图库打开；
            showPhoto.logic_id = self.logic_id;
            [self.navigationController pushViewController:showPhoto animated:true];
        }
    }]];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //取消；
    }]];
    
    //弹出提示框；
    [self presentViewController:self.alert animated:true completion:nil];
}


- (void)sliderValueChanged:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        UISlider * slider = (UISlider *)sender;
        if(fabs(slider.value-self.temp)>=8)
        {
            if(slider.value<=8)
            {
                slider.value=0;
            }
            else if(slider.value>=92)
            {
                slider.value=100;
            }
            self.temp=(int)slider.value;
            NSLog(@"可以发送请求%d",(int)slider.value);
        }
        
    }
}
@end

















