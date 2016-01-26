//
//  YSRGBPatternViewController.m
//  Zju_SmartHome
//
//  Created by lysongzi on 15/12/30.
//  Copyright © 2015年 GJY. All rights reserved.
//

#import "YSRGBPatternViewController.h"
#import "YSProductViewController.h"
#import "JYPattern.h"
#import "JYPatternSqlite.h"
#import "DLLampControlRGBModeViewController.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "JYChangePatternBGController.h"
#import "LYSImageStore.h"
#import "HttpRequest.h"
#import "JYPatternBackStatus.h"
#import "AppDelegate.h"
#import "SDWebImageManager.h"

#define CELL_NUMBER 5
#define DEFAULT_CELL_NUMBER 7
#define UISCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface YSRGBPatternViewController ()<UIScrollViewDelegate,UIImagePickerControllerDelegate, UIPopoverControllerDelegate,UINavigationControllerDelegate,ChangePatternBGDelegate>

@property (weak, nonatomic) IBOutlet UILabel *patternNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bkgImageView;
//图片选择按钮
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
//音乐播放按钮
@property (weak, nonatomic) IBOutlet UIButton *musicButton;
//中间亮圆圈
@property (weak, nonatomic) IBOutlet UIView *lightView;

//模式切换
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *patterns;
@property (strong, nonatomic) NSMutableArray *cellsView;

@property (assign) NSInteger cellWidth;
@property (assign) NSInteger cellHeight;

//音乐盒当前状态
@property (copy, nonatomic) NSString *musicBox_State;

//记录当前居中的模式索引
@property (assign) NSInteger selectedIndex;
//定义JYSqlite对象
@property(nonatomic,strong)JYPatternSqlite *jynewSqlite;


//有关照片切换背景图的属性；
@property (nonatomic,strong) UIPopoverController *imagePickerPopover;
@property (nonatomic,strong) UIAlertController *alert;

@property(nonatomic,copy)NSString *tableName;

//音乐播放框
@property (weak, nonatomic) IBOutlet UIView *musicView;
//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *musicPlay;
//上一首
@property (weak, nonatomic) IBOutlet UIButton *musicPre;
//下一首
@property (weak, nonatomic) IBOutlet UIButton *musicNext;
//音乐框背景图
@property (weak, nonatomic) IBOutlet UIImageView *musicBkg;

//记录音乐框里各种空间位置的参数
@property CGRect musicViewFrame;
@property CGRect musicBkgFrame;
@property CGRect musicPreFrame;
@property CGRect musicNextFrame;
@property CGRect musicPlayFrame;


@property(nonatomic,strong)NSMutableArray *BackPatternArray;
@end

@implementation YSRGBPatternViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"看看是从哪里进到这个模式界面：%@",self.room_name);

    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //专门存储模式的表
    self.tableName=[NSString stringWithFormat:@"patternTable%@",appDelegate.user_id];
    NSLog(@"看看表明%@ %@",self.tableName,self.logic_id);
    
    [self setNaviBarItemButton];
    
    self.cellWidth = UISCREEN_WIDTH / CELL_NUMBER;
    self.cellHeight = self.scrollView.frame.size.height;
    
    [self.pictureButton setBackgroundImage:[UIImage imageNamed:@"switch_press"] forState:UIControlStateHighlighted];
    [self.musicButton setBackgroundImage:[UIImage imageNamed:@"music_icon_press"] forState:UIControlStateHighlighted];
    
    //初始化默认模型数据
    [self initPatternData];
    
    //初始化音乐框
    float gap = self.musicButton.frame.size.width / 2;
    
    self.musicViewFrame = self.musicView.frame;
    self.musicBkgFrame = self.musicBkg.frame;
    self.musicNextFrame = self.musicNext.frame;
    self.musicPreFrame = self.musicPre.frame;
    self.musicPlayFrame = self.musicPlay.frame;
    
    //默认不显示
    self.musicView.frame = CGRectMake(self.musicViewFrame.origin.x + self.musicViewFrame.size.width - gap, self.musicViewFrame.origin.y, 0, self.musicViewFrame.size.height);
    
    //进行适配6
    float width = [[UIScreen mainScreen] bounds].size.width;
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
    
    self.musicViewFrame = CGRectMake(self.musicViewFrame.origin.x * ratio, self.musicViewFrame.origin.y * ratio, self.musicViewFrame.size.width * ratio, self.musicViewFrame.size.height * ratio);
    
    self.musicBkgFrame = CGRectMake(self.musicBkgFrame.origin.x * ratio, self.musicBkgFrame.origin.y * ratio, self.musicBkgFrame.size.width * ratio, self.musicBkgFrame.size.height * ratio);
    
    self.musicNextFrame = CGRectMake(self.musicNextFrame.origin.x * ratio, self.musicNextFrame.origin.y * ratio, self.musicNextFrame.size.width * ratio, self.musicNextFrame.size.height * ratio);
    
    self.musicPlayFrame = CGRectMake(self.musicPlayFrame.origin.x * ratio, self.musicPlayFrame.origin.y * ratio, self.musicPlayFrame.size.width * ratio, self.musicPlayFrame.size.height * ratio);
    
    self.musicPreFrame = CGRectMake(self.musicPreFrame.origin.x * ratio, self.musicPreFrame.origin.y * ratio, self.musicPreFrame.size.width * ratio, self.musicPreFrame.size.height * ratio);
    
    //0表示未弹出状态，1表示弹出状态
    self.musicView.tag = 0;
    //0表示暂停状态，1表示播放状态
    self.musicPlay.tag = 1;
    
    //设置各种按钮点击图片
    [self.musicNext setBackgroundImage:[UIImage imageNamed:@"music_xiayishou_icon_press"] forState:UIControlStateHighlighted];
    [self.musicPre setBackgroundImage:[UIImage imageNamed:@"music_shangyishou_icon_press"] forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer * tapLight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBkg:)];
    [self.lightView setUserInteractionEnabled:YES];
    [self.lightView addGestureRecognizer:tapLight];
    
    //默认是关灯
    self.pictureButton.tag = 0;
    
    //获取灯的状态
    [self getLightStatus];
    [self initMusicBox];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.tag_Back==2)
    {
        //初始化默认模型数据
        [self initPatternData];
        //初始化scrollView
       // [self initScrollView];
        
        //定位到新添加的模式
        [self.scrollView setContentOffset:CGPointMake(self.cellWidth * (self.patterns.count - 2), 0)];
        //设置当前居中为新添加的模式，并更新背景和文字
        self.selectedIndex = self.patterns.count - 2;
        [self updateCellBackground:(int)self.selectedIndex];
        self.tag_Back = 0;
    }
    else
    {
        //NSLog(@"这里应该是修改模式背景图片返回来的");
    }
}

- (void)initMusicBox
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];
    self.musicBox_State = [userDefault valueForKey:@"music_state"];
    
    //NSLog(@"sadasd%@", self.musicBox_State);
    if ([self.musicBox_State isEqualToString:@"stop"])
    {
        self.musicPlay.tag = 0;
        
        [self.musicPlay setBackgroundImage:[UIImage imageNamed:@"music_zanting"] forState:UIControlStateNormal];
    }
    else if ([self.musicBox_State isEqualToString:@"start"])
    {
        self.musicPlay.tag = 1;
        [self.musicPlay setBackgroundImage:[UIImage imageNamed:@"music_bofang"] forState:UIControlStateNormal];
    }
    else
    {
        //默认开启音乐盒并播放
        [HttpRequest getMusicActionfromProtol:@"power_on" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"请求成功：%@",result);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败：%@",error);
        }];
    }
}

//初始化模式的数据
- (void)initPatternData
{
    //初始化
    JYPatternSqlite *jynewSqlite=[[JYPatternSqlite alloc]init];
    jynewSqlite.patterns=[[NSMutableArray alloc]init];
    self.jynewSqlite=jynewSqlite;
    
    //打开数据库
    [self.jynewSqlite openDB];
    //创建表（如果已经存在时不会再创建的）
    [self.jynewSqlite createTable:self.tableName];
    
    //获取表中指定逻辑id的所有记录
    [self.jynewSqlite getAllRecordFromTable:self.tableName ByLogic_id:self.logic_id];
    
    if(self.jynewSqlite.patterns.count == 0)
    {
        NSLog(@"刚开始进来数据库没有数据的");
        if([self.room_name isEqualToString:@"-1"])
        {
            NSLog(@"走的是单品");
            //1.创建请求管理对象
            AFHTTPRequestOperationManager *mgr=[AFHTTPRequestOperationManager manager];
            
            //2.说明服务器返回的是json参数
            mgr.responseSerializer=[AFJSONResponseSerializer serializer];
            
            //3.封装请求参数
            NSMutableDictionary *params=[NSMutableDictionary dictionary];
            params[@"is_app"]=@"1";
            params[@"sceneconfig.room_name"]=@"-1";
            params[@"sceneconfig.tag"]=@"0";
            params[@"sceneconfig.equipment_logic_id"]=self.logic_id;
            
            //4.发送请求
            [mgr POST:@"http://60.12.220.16:8888/paladin/Sceneconfig/find" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 
                 JYPatternBackStatus *backStatus=[JYPatternBackStatus statusWithDict:responseObject];
                 for(int i=0;i<backStatus.patternArray.count;i++)
                 {
                     JYPattern *pattern=backStatus.patternArray[i];
                     NSLog(@"%@ %@ %@ %@ %@ %@ %@",pattern.logic_id,pattern.name,pattern.logoName, pattern.bkgName,pattern.param1,pattern.param2,pattern.param3);
                     
                     [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"logic_id" field1Value:pattern.logic_id andField2:@"name" field2Value:pattern.name andField3:@"bkgName" field3Value:pattern.bkgName andField4:@"param1" field4Value:pattern.param1 andField5:@"param2" field5Value:pattern.param2 andField6:@"param3" field6Value:pattern.param3];
                 }
                 
                 [self.jynewSqlite getAllRecordFromTable:self.tableName ByLogic_id:self.logic_id];
                 self.patterns=self.jynewSqlite.patterns;
                 //最后一个自定义按钮
                 JYPattern *pattern=[[JYPattern alloc]init];
                 pattern.name=@"自定义";
                 [self.patterns addObject:pattern];
                 
                 for(int i=0;i<self.patterns.count;i++)
                 {
                     JYPattern *pattern=self.patterns[i];
                     if([pattern.name isEqualToString:@"柔和"])
                     {
                         pattern.logoName=@"rouhe_icon";
                     }
                     else if([pattern.name isEqualToString:@"舒适"])
                     {
                         pattern.logoName=@"shushi_icon";
                     }
                     else if([pattern.name isEqualToString:@"明亮"])
                     {
                         pattern.logoName=@"mingliang_icon";
                     }
                     else if([pattern.name isEqualToString:@"跳跃"])
                     {
                         pattern.logoName=@"tiaoyue_icon";
                     }
                     else if([pattern.name isEqualToString:@"R"])
                     {
                         pattern.logoName=@"R";
                     }
                     else if([pattern.name isEqualToString:@"G"])
                     {
                         pattern.logoName=@"G";
                     }
                     else if([pattern.name isEqualToString:@"B"])
                     {
                         pattern.logoName=@"B";
                     }
                     else if([pattern.name isEqualToString:@"自定义"])
                     {
                         pattern.logoName=@"zidingyi";
                     }
                     else
                     {
                         pattern.logoName=@"zidingyi_icon";
                         NSLog(@"lalalalal");
                         if(![pattern.bkgName isEqualToString:@"rouhe_bg"])
                         {
                             //做加载图片
                             NSLog(@"http://60.12.220.16:8888/paladin/Static/images/protrait/%@, %@",pattern.bkgName, pattern.bkgName);
                             
                             SDWebImageManager *manager = [SDWebImageManager sharedManager];
                             NSString *imageStr=[NSString stringWithFormat:@"http://60.12.220.16:8888/paladin/Static/images/protrait/%@.jpg",pattern.bkgName];
                             NSURL *imageUrl=[NSURL URLWithString:imageStr];
                    
                             [manager downloadImageWithURL:imageUrl
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize)
                                                  {
                                                      // progression tracking code
                                                  }
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     if (image)
                                                     {
                                                         // do something with image
                                                         //NSLog(@"hhhhh");
                                                         NSData *data = UIImageJPEGRepresentation(image, 1.0);
                                                         NSString *path = [[LYSImageStore sharedStore] imagePathForKey:pattern.bkgName];
                                                         NSLog(@"%@",path);
                                                         [data writeToFile:path atomically:YES];
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"这里没收到图片.");
                                                     }
                                                 }];
                         }
                         
                         
                     }
                 }
                 for(int i=0;i<self.patterns.count;i++)
                 {
                     JYPattern *pattern=self.patterns[i];
                     NSLog(@"======%@ %@ %@  %@ %@ %@ %@",pattern.logic_id,pattern.name,pattern.logoName, pattern.bkgName,pattern.param1,pattern.param2,pattern.param3);
                 }
                 //初始化scrollView
                 [self initScrollView];
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 [MBProgressHUD showError:@"服务器加载数据失败"];
             }];
            
        }
        else
        {
            NSLog(@"走的是家居");
            //1.创建请求管理对象
            AFHTTPRequestOperationManager *mgr=[AFHTTPRequestOperationManager manager];
            
            //2.说明服务器返回的是json参数
            mgr.responseSerializer=[AFJSONResponseSerializer serializer];
            
            //3.封装请求参数
            NSMutableDictionary *params=[NSMutableDictionary dictionary];
            params[@"is_app"]=@"1";
            params[@"sceneconfig.room_name"]=self.room_name;
            params[@"sceneconfig.tag"]=@"0";
            params[@"sceneconfig.equipment_logic_id"]=self.logic_id;
            
            NSLog(@"纳你");
            NSLog(@"%@ %@",self.room_name,self.logic_id);
            
            //4.发送请求
            [mgr POST:@"http://60.12.220.16:8888/paladin/Sceneconfig/find" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 
                 JYPatternBackStatus *backStatus=[JYPatternBackStatus statusWithDict:responseObject];
                 for(int i=0;i<backStatus.patternArray.count;i++)
                 {
                     JYPattern *pattern=backStatus.patternArray[i];
                     NSLog(@"%@ %@ %@ %@ %@ %@ %@",pattern.logic_id,pattern.name,pattern.logoName, pattern.bkgName,pattern.param1,pattern.param2,pattern.param3);
                     
                     [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"logic_id" field1Value:pattern.logic_id andField2:@"name" field2Value:pattern.name andField3:@"bkgName" field3Value:pattern.bkgName andField4:@"param1" field4Value:pattern.param1 andField5:@"param2" field5Value:pattern.param2 andField6:@"param3" field6Value:pattern.param3];
                 }
                 
                 [self.jynewSqlite getAllRecordFromTable:self.tableName ByLogic_id:self.logic_id];
                 self.patterns=self.jynewSqlite.patterns;
                 //最后一个自定义按钮
                 JYPattern *pattern=[[JYPattern alloc]init];
                 pattern.name=@"自定义";
                 [self.patterns addObject:pattern];
                 
                 for(int i=0;i<self.patterns.count;i++)
                 {
                     JYPattern *pattern=self.patterns[i];
                     if([pattern.name isEqualToString:@"柔和"])
                     {
                         pattern.logoName=@"rouhe_icon";
                     }
                     else if([pattern.name isEqualToString:@"舒适"])
                     {
                         pattern.logoName=@"shushi_icon";
                     }
                     else if([pattern.name isEqualToString:@"明亮"])
                     {
                         pattern.logoName=@"mingliang_icon";
                     }
                     else if([pattern.name isEqualToString:@"跳跃"])
                     {
                         pattern.logoName=@"tiaoyue_icon";
                     }
                     else if([pattern.name isEqualToString:@"R"])
                     {
                         pattern.logoName=@"R";
                     }
                     else if([pattern.name isEqualToString:@"G"])
                     {
                         pattern.logoName=@"G";
                     }
                     else if([pattern.name isEqualToString:@"B"])
                     {
                         pattern.logoName=@"B";
                     }
                     else if([pattern.name isEqualToString:@"自定义"])
                     {
                         pattern.logoName=@"zidingyi";
                     }
                     else
                     {
                         pattern.logoName=@"zidingyi_icon";
                         if(![pattern.bkgName isEqualToString:@"rouhe_bg"])
                         {
                             //做加载图片
                             NSLog(@"http://60.12.220.16:8888/paladin/Static/images/protrait/%@, %@",pattern.bkgName, pattern.bkgName);
                             
                             SDWebImageManager *manager = [SDWebImageManager sharedManager];
                             NSString *imageStr=[NSString stringWithFormat:@"http://60.12.220.16:8888/paladin/Static/images/protrait/%@.jpg",pattern.bkgName];
                             NSURL *imageUrl=[NSURL URLWithString:imageStr];
                             
                             [manager downloadImageWithURL:imageUrl
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize)
                              {
                                  // progression tracking code
                              }
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     if (image)
                                                     {
                                                         // do something with image
                                                         NSLog(@"hhhhh");
                                                         NSData *data = UIImageJPEGRepresentation(image, 1.0);
                                                         NSString *path = [[LYSImageStore sharedStore] imagePathForKey:pattern.bkgName];
                                                         NSLog(@"%@",path);
                                                         [data writeToFile:path atomically:YES];
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"这里没收到图片.");
                                                     }
                                                 }];
                         }
                     }
                 }
                 for(int i=0;i<self.patterns.count;i++)
                 {
                     JYPattern *pattern=self.patterns[i];
                     NSLog(@"======%@ %@ %@  %@ %@ %@ %@",pattern.logic_id,pattern.name,pattern.logoName, pattern.bkgName,pattern.param1,pattern.param2,pattern.param3);
                 }
                 //初始化scrollView
                 [self initScrollView];
                 
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 [MBProgressHUD showError:@"服务器加载数据失败"];
             }];
        }
    }
    else
    {
        NSLog(@"数据库已经有数据");
        self.patterns=self.jynewSqlite.patterns;
        NSLog(@"%ld", self.patterns.count);
        
        for(int i=0;i<self.patterns.count;i++)
        {
            JYPattern *pattern=self.patterns[i];
            NSLog(@"======%@ %@ %@ %@ %@ %@",pattern.logic_id,pattern.name,pattern.bkgName,pattern.param1,pattern.param2,pattern.param3);
        }
        //最后一个自定义按钮
        JYPattern *pattern=[[JYPattern alloc]init];
        pattern.name=@"自定义";
        [self.patterns addObject:pattern];
        
        for(int i=0;i<self.patterns.count;i++)
        {
            JYPattern *pattern=self.patterns[i];
            if([pattern.name isEqualToString:@"柔和"])
            {
                pattern.logoName=@"rouhe_icon";
            }
            else if([pattern.name isEqualToString:@"舒适"])
            {
                pattern.logoName=@"shushi_icon";
            }
            else if([pattern.name isEqualToString:@"明亮"])
            {
                pattern.logoName=@"mingliang_icon";
            }
            else if([pattern.name isEqualToString:@"跳跃"])
            {
                pattern.logoName=@"tiaoyue_icon";
            }
            else if([pattern.name isEqualToString:@"R"])
            {
                pattern.logoName=@"R";
            }
            else if([pattern.name isEqualToString:@"G"])
            {
                pattern.logoName=@"G";
            }
            else if([pattern.name isEqualToString:@"B"])
            {
                pattern.logoName=@"B";
            }
            else if([pattern.name isEqualToString:@"自定义"])
            {
                pattern.logoName=@"zidingyi";
            }
            else
            {
                pattern.logoName=@"zidingyi_icon";
            }
        }
        //初始化scrollView
        [self initScrollView];
    }
}

//初始化scrollView的内容
- (void)initScrollView
{
    self.scrollView.contentSize = CGSizeMake(self.cellWidth * (self.patterns.count + 4), self.cellHeight);
    
    //清楚scrollView的子视图
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.decelerationRate = 0.95f;
    
    if (!self.cellsView)
    {
        self.cellsView = [NSMutableArray array];
    }
    else
    {
        [self.cellsView removeAllObjects];
    }
    
    //添加两个空白的块
    for (int i = 0; i < 2; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cellWidth, self.cellWidth)];
        subView.backgroundColor = [UIColor clearColor];
        
        [view addSubview:subView];
        [self.scrollView addSubview:view];
    }
    
    //默认的六个块
    for (int i = 2; i < self.patterns.count + 2; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.cellWidth - 10, self.cellWidth - 10)];
        image.image = [UIImage imageNamed:[self.patterns[i-2] logoName]];
        image.tag = i - 2;
        view.tag = i -2;
        [image setUserInteractionEnabled:YES];
        
        //添加按钮添加触摸手势
        if (i == self.patterns.count + 1)
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapGestureEvent:)];
            [image addGestureRecognizer:tap];
        }
        //别的模式点击进入模式编辑和向上删除滑动删除手势
        else
        {
            //添加点击手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(patternTapGestureEvent:)];
            [image addGestureRecognizer:tap];
            
            //添加向上滑手势
            UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDeletePattern:)];
            [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
            [image addGestureRecognizer:swipeGesture];
        }
        
        [view addSubview:image];
        [self.cellsView addObject:view];
        [self.scrollView addSubview:view];
    }
    
    //添加两个空白的块
    for (long i = self.patterns.count + 2; i < self.patterns.count + 4; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cellWidth, self.cellWidth)];
        subView.backgroundColor = [UIColor clearColor];
        
        [view addSubview:subView];
        [self.scrollView addSubview:view];
    }
    
    //设置默认居中为第三个模式
    [self.scrollView setContentOffset:CGPointMake(self.cellWidth * 2, 0) animated:YES];
    self.selectedIndex = 2;
    //设置背景颜色和文字
    [self updateCellBackground:2];
}

//添加按钮的添加模式事件
- (void)addTapGestureEvent:(UIGestureRecognizer *)gr
{
    UIImageView *image = (UIImageView *)gr.self.view;
    
    //被点击的不是居中的元素，则进行滑动
    if (image.tag != self.selectedIndex)
    {
        float destination = self.scrollView.contentOffset.x + (image.tag - self.selectedIndex) * self.cellWidth;
        self.selectedIndex = image.tag;
        [self.scrollView setUserInteractionEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(destination, 0) animated:YES];
    }
    //否则就是点击了居中的元素
    else
    {
        DLLampControlRGBModeViewController *rgbVc=[[DLLampControlRGBModeViewController alloc]init];
        //传这两个值用于通过逻辑id控制灯，通过逻辑id和电器名进行表的添加操作
        rgbVc.logic_id=self.logic_id;
        rgbVc.furnitureName=self.furnitureName;
        rgbVc.tableName=self.tableName;
        rgbVc.area=self.room_name;
        [self.navigationController pushViewController:rgbVc animated:YES];
    }
}

//获取灯的状态
- (void)getLightStatus
{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    //2.说明服务器返回的是json参数
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //3.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"is_app"] = @"1";
    params[@"logic_id"] = self.logic_id;
    
    //4.发送请求
    [mgr POST:@"http://60.12.220.16:8888/Weixin/Device/getStatus" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"这里是获取灯的状态%@",responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"返回失败了吧：%@",error);
     }];

}

//编辑模式事件
- (void)patternTapGestureEvent:(UIGestureRecognizer *)gr
{
    UIImageView *image = (UIImageView *)gr.self.view;
    
    //被点击的不是居中的元素，则进行滑动
    if (image.tag != self.selectedIndex)
    {
        float destination = self.scrollView.contentOffset.x + (image.tag - self.selectedIndex) * self.cellWidth;
        self.selectedIndex = image.tag;
        [self.scrollView setUserInteractionEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(destination, 0) animated:YES];
    }
    //否则就是点击了居中的元素
    else
    {
        //NSLog(@"进入编辑模式的界面");
    }
}

//向上滑动删除
- (void)swipeToDeletePattern:(UIGestureRecognizer *)gr
{
    UIView *view = (UIView *)gr.self.view;
    
    //想删除的不是居中的元素，或者默认模式不允许删除，或者是添加按钮键
    if (view.tag != self.selectedIndex || self.selectedIndex < DEFAULT_CELL_NUMBER || view.tag == self.patterns.count - 1)
    {
        return;
    }
    
    JYPattern *pattern=[self.patterns objectAtIndex:view.tag];
    //从模型中删除
    [self.patterns removeObjectAtIndex:view.tag];
    
    [HttpRequest deletePatternFromServerProduct:self.logic_id andWithPatternName:pattern.name withArea:self.room_name success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"看看返回的数据是啥呢？%@",str);
         
         [MBProgressHUD showSuccess:@"删除模式成功"];
         [self.cellsView[view.tag] setHidden:YES];
         
         UIView * changeView;
         for (long i = view.tag + 1; i < self.cellsView.count; i++)
         {
             changeView = (UIView *)self.cellsView[i];
             changeView.tag -= 1;
             UIImageView *subImage = [[changeView subviews] lastObject];
             subImage.tag -= 1;
             
             CGPoint point = changeView.center;
             point.x -= self.cellWidth;
             [UIView beginAnimations:nil context:nil];
             [UIView setAnimationDuration:0.3];
             [changeView setCenter:point];
             
             if (i == view.tag + 1)
             {
                 [subImage setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
             }
             else if (i == view.tag + 2)
             {
                 [subImage setTransform:CGAffineTransformMakeScale(0.85f, 0.85f)];
             }
             else
             {
                 [subImage setTransform:CGAffineTransformMakeScale(0.6f, 0.6f)];
             }
             
             [UIView commitAnimations];
         }
         
         //移除该cell的视图
         [self.cellsView removeObjectAtIndex:view.tag];
         //更新scrollview的内容宽度
         self.scrollView.contentSize = CGSizeMake(self.cellWidth * (self.patterns.count + 4), self.cellHeight);
         //更新背景和文字
         [self updateCellBackground:(int)view.tag];
         [self.jynewSqlite deleteRecordWithLogicID:pattern.logic_id andWithName:pattern.name inTable:self.tableName];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [MBProgressHUD showError:@"删除模式失败"];
     }];
}

//弹出选择更换背景图
- (void)changeBkg:(UIGestureRecognizer *)gr
{
    if (self.selectedIndex == (self.patterns.count - 1)) {
        return;
    }
    
    if (self.selectedIndex < DEFAULT_CELL_NUMBER) {
        //默认模式不允许修改背景图
        [MBProgressHUD showError:@"默认模式不允许修改背景图"];
        return;
    }
    
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.delegate=self;
    //这里可以设置是否允许编辑图片；
    imagePicker.allowsEditing = false;
    
    
    /**
     *  应该在这里让用户选择是打开摄像头还是图库；
     */
    //初始化提示框；
    self.alert = [UIAlertController alertControllerWithTitle:@"更换背景图片" message:nil preferredStyle:  UIAlertControllerStyleActionSheet];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //创建UIPopoverController对象前先检查当前设备是不是ipad
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
//            self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
//            self.imagePickerPopover.delegate = self;
//            [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
//                                            permittedArrowDirections:UIPopoverArrowDirectionAny
//                                                            animated:YES];
        }
        else
        {
            //跳到ShowPhoto页面；
            JYChangePatternBGController *showPhoto = [[JYChangePatternBGController alloc] init];
            showPhoto.openType = UIImagePickerControllerSourceTypeCamera;//从照相机打开；
            showPhoto.delegate=self;
            [self.navigationController pushViewController:showPhoto animated:true];
        }
    }]];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                           {
                               imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                               
                               //创建UIPopoverController对象前先检查当前设备是不是ipad
                               if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                               {
//                                   self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
//                                   self.imagePickerPopover.delegate = self;
//                                   [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
//                                                                   permittedArrowDirections:UIPopoverArrowDirectionAny
//                                                                                   animated:YES];
                               }
                               else
                               {
                                   //跳到ShowPhoto页面；
                                   JYChangePatternBGController *showPhoto = [[JYChangePatternBGController alloc] init];
                                   showPhoto.logic_id=self.logic_id;
                                   showPhoto.openType = UIImagePickerControllerSourceTypePhotoLibrary;
                                   //从图库打开；
                                   showPhoto.delegate=self;
                                   [self.navigationController pushViewController:showPhoto animated:true];
                               }
                           }]];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
    
    //弹出提示框；
    [self presentViewController:self.alert animated:true completion:nil];
}

//点击开关灯
- (IBAction)pictureClick:(id)sender
{
    //0表示为关灯状态，1表示开灯状态
    UIButton *swichButton = (UIButton *)sender;
    
    //关灯变开灯
    if (!swichButton.tag)
    {
        swichButton.tag = 1;
        [swichButton setBackgroundImage:[UIImage imageNamed:@"switch_unpress"] forState:UIControlStateNormal];
        //做网络请求
        [HttpRequest sendRGBBrightnessToServer:self.logic_id brightnessValue:@"100"
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           
                                           NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                           NSLog(@"成功: %@", string);
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"失败: %@", error);
                                           [MBProgressHUD showError:@"请检查网关"];
                                           
                                       }];
    }
    //开灯变关灯
    else
    {
        swichButton.tag = 0;
        [swichButton setBackgroundImage:[UIImage imageNamed:@"switch_icon_off"] forState:UIControlStateNormal];
        //做网络请求
        [HttpRequest sendRGBBrightnessToServer:self.logic_id brightnessValue:@"0"
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           
                                           NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                           NSLog(@"成功: %@", string);
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"失败: %@", error);
                                           [MBProgressHUD showError:@"请检查网关"];
                                           
                                       }];
    }

}

//修改背景图片的代理方法
-(void)changBG:(UIImage *)image
{
    //为新图片创建一个标示文件名的值
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *imageName = [uuid UUIDString];
    //接下来存储改文件到本地，以及更新模型的数据
    JYPattern *pattern = self.patterns[self.selectedIndex];
    pattern.bkgName = imageName;
    [[LYSImageStore sharedStore] setImage:image forKey:imageName];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSDictionary *parameters = @;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    
    params[@"is_app"]=@"1";
    params[@"sceneconfig.scene_name"]=pattern.name;
    params[@"sceneconfig.tag"]=@"0";
    params[@"sceneconfig.equipment_logic_id"]=self.logic_id;
    params[@"sceneconfig.image_name"]=imageName;
    
    NSLog(@"%@ %@ %@ %@",pattern.name,self.logic_id,imageName,params[@"sceneconfig.tag"]);

    
    NSString *string=[[LYSImageStore sharedStore]imagePathForKey:imageName];
    NSLog(@"999 %@",string);
    //NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    
    NSURL *filePath = [NSURL fileURLWithPath:string];
    
    [manager POST:@"http://60.12.220.16:8888/paladin/Sceneconfig/portrait" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        [formData appendPartWithFileURL:filePath name:@"sceneconfig.file" error:nil];
    }
        success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"Success: %@ %@", responseObject,responseObject[@"msg"]);
        //更新图片到sqlite
        [self.jynewSqlite updateRecordByLogicID:self.logic_id andByName:pattern.name withNewBKG:imageName inTable:self.tableName];
        //这里显示图片
        [self updateCellBackground:(int)self.selectedIndex];
        
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
    }];
}

//点击播放音乐的响应事件
- (IBAction)musicClick:(id)sender
{
    if (!self.musicView.tag)
    {
        //弹出音乐界面
        [UIView animateWithDuration:0.4 animations:^{
            self.musicView.frame = CGRectMake(self.musicViewFrame.origin.x, self.musicViewFrame.origin.y, self.musicViewFrame.size.width, self.musicViewFrame.size.height);
            
            self.musicBkg.frame = CGRectMake(self.musicBkgFrame.origin.x, self.musicBkgFrame.origin.y, self.musicBkgFrame.size.width, self.musicBkgFrame.size.height);
            
            self.musicNext.frame = CGRectMake(self.musicNextFrame.origin.x, self.musicNextFrame.origin.y, self.musicNextFrame.size.width, self.musicNextFrame.size.height);
            
            self.musicPre.frame = CGRectMake(self.musicPreFrame.origin.x, self.musicPreFrame.origin.y, self.musicPreFrame.size.width, self.musicPreFrame.size.height);
            
            self.musicPlay.frame = CGRectMake(self.musicPlayFrame.origin.x, self.musicPlayFrame.origin.y, self.musicPlayFrame.size.width, self.musicPlayFrame.size.height);
        }];
        
        self.musicView.tag = 1;
    }
    else
    {
        //缩回音乐界面
        float gap = self.musicButton.frame.size.width / 2;
        [UIView animateWithDuration:0.4 animations:^{
            self.musicView.frame = CGRectMake(self.musicViewFrame.origin.x + self.musicViewFrame.size.width - gap, self.musicViewFrame.origin.y, 0, self.musicViewFrame.size.height);
        }];
        self.musicView.tag = 0;
    }
    
}


- (IBAction)musicPreClick:(id)sender
{
    NSLog(@"这里是上一首");
    [HttpRequest getMusicActionfromProtol:@"previous" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"音乐请求成功：%@",result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"音乐请求失败：%@",error);
    }];
}

- (IBAction)musicNextClick:(id)sender
{
    NSLog(@"这里是下一首");
    
    [HttpRequest getMusicActionfromProtol:@"next" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"音乐请求成功：%@",result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"音乐请求失败：%@",error);
    }];
}

- (IBAction)musicPlayClick:(id)sender
{
    
    UIButton *play = (UIButton *)sender;
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];

    //暂停变播放
    if (!play.tag)
    {
        NSLog(@"这里是播放");
        
        //接下来在这里写播放的代码
        [HttpRequest getMusicActionfromProtol:@"start" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"请求成功：%@",result);
            
            [userDefault setObject:@"start" forKey:@"music_state"];
            play.tag = 1;
            [self.musicPlay setBackgroundImage:[UIImage imageNamed:@"music_bofang"] forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败：%@",error);
        }];
    }
    else
    {
        NSLog(@"这里是暂停");
        
        //接下来在这里写播放的代码
        
        [HttpRequest getMusicActionfromProtol:@"stop" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"请求成功：%@",result);
            
            [userDefault setObject:@"stop" forKey:@"music_state"];
            play.tag = 0;
            [self.musicPlay setBackgroundImage:[UIImage imageNamed:@"music_zanting"] forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败：%@",error);
        }];
    }
}


#pragma mark - scrollView中cell的动态操作

- (void)addPatternToScrollView:(JYPattern *)pattern
{
    //先把该模式添加到数组中
    [self.patterns insertObject:pattern atIndex:self.patterns.count];
}

#pragma mark - UIScrollViewDelegate 协议的实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cellJumpToIndex:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self cellJumpToIndex:scrollView];
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->x >= (self.patterns.count - 1) * self.cellWidth)
    {
        [self updateCellBackground:(int)self.patterns.count - 1];
    }
    else if(targetContentOffset->x <= 0)
    {
        //变得太快了
        [self updateCellBackground:0];
        JYPattern *pattern=self.patterns[0];
        
        NSString *r = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param1 intValue]]];
        NSString *g = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param2 intValue]]];
        
        NSString *b = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param3 intValue]]];
        
        
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [MBProgressHUD showError:@"请检查网关"];
        }];
    }
}

//滑动的时候就会调用的函数，在这里写动画
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //处理每一个cell，计算它的缩放比例
    for (int i = 0; i < self.cellsView.count; i++)
    {
        float lead = self.cellWidth * (i + 2);
        float tail = self.cellWidth * (i + 3);
        
        //在屏幕左侧
        if (self.scrollView.contentOffset.x > tail)
        {
            [self viewToScale:0.6 target:self.cellsView[i]];
        }
        //在屏幕右侧
        else if ((self.scrollView.contentOffset.x + UISCREEN_WIDTH) < lead)
        {
            [self viewToScale:0.6 target:self.cellsView[i]];
        }
        //现在在界面上
        else
        {
            float sub = lead - self.scrollView.contentOffset.x;
            //前半部分
            if (sub <= 2 * self.cellWidth)
            {
                float rate = sub / (2 * self.cellWidth) * 0.5 + 0.6;
                rate = rate > 1.0 ? 1.0 : rate;
                [self viewToScale:rate target:self.cellsView[i]];
            }
            else
            {
                float rate = (UISCREEN_WIDTH - sub - self.cellWidth) / (2 * self.cellWidth) * 0.5 + 0.6;
                rate = rate > 1.0 ? 1.0 : rate;
                [self viewToScale:rate target:self.cellsView[i]];
            }
        }
    }
}

- (void)viewToScale:(float)scale target:(UIView *)view
{
    UIImageView *image = [[view subviews] lastObject];
    [UIView beginAnimations:@"scale" context:nil];
    image.transform = CGAffineTransformMakeScale(scale, scale);
    [UIView commitAnimations];
}

//滑动动画结束时调用的函数
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //根据居中的选项更新背景和文字
    [self updateCellBackground:(int)self.selectedIndex];
    [self.scrollView setUserInteractionEnabled:YES];
    
    JYPattern *pattern = self.patterns[(int)self.selectedIndex];
    
    NSString *r = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param1 intValue]]];
    NSString *g = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param2 intValue]]];
    
    NSString *b = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.param3 intValue]]];
    
    if([pattern.name isEqualToString:@"自定义"])
    {
        NSLog(@"这里是自定义，不需要发送网络请求");
    }
    else if([pattern.name isEqualToString:@"跳跃"])
    {
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"%@",string);
         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"请检查网关"];
         }];
        
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:@"255" greenValue:@"0" blueValue:@"0"
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"%@",string);
         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"请检查网关"];
         }];
        
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:@"0" greenValue:@"255" blueValue:@"0"
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"%@",string);
         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"请检查网关"];
         }];
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:@"0" greenValue:@"0" blueValue:@"255"
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"%@",string);
         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"请检查网关"];
         }];
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:@"100" greenValue:@"200" blueValue:@"200"
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"%@",string);
         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"请检查网关"];
         }];
    }
    else
    {
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [MBProgressHUD showError:@"请检查网关"];
        }];
 
    }
}

//计算位置，居中选中的cell
- (void)cellJumpToIndex:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x < self.cellWidth * 0.5)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (self.scrollView.contentOffset.x > self.cellWidth * (self.patterns.count + 1.5))
    {
        [self.scrollView setContentOffset:CGPointMake(self.cellWidth * (self.patterns.count + 1), 0) animated:YES];
    }
    
    int index = (int)(self.scrollView.contentOffset.x / self.cellWidth + 0.5);
    [self.scrollView setContentOffset:CGPointMake(self.cellWidth * index, 0) animated:YES];
    
    //选定某个模式，进行模式更新等操作
    self.selectedIndex = index;
}

//滑动到某个cell时更新视图的方法
- (void)updateCellBackground:(int)index
{
    self.patternNameLabel.text = [self.patterns[index] name];
    
    //如果是添加模式按钮则不修改图片
    if (index != self.patterns.count - 1)
    {
        //为默认模式，加载默认图片
        if (self.selectedIndex < DEFAULT_CELL_NUMBER)
        {
            self.bkgImageView.image = [UIImage imageNamed:[self.patterns[index] bkgName]];
        }
        //自定义图片加载自定义模式
        else
        {
            JYPattern * selectedPattern = self.patterns[self.selectedIndex];
            UIImage *image = [[LYSImageStore sharedStore] imageForKey:selectedPattern.bkgName];
            if (!image)
            {
                //这里加载的是自定义默认图片
                self.bkgImageView.image = [UIImage imageNamed:[self.patterns[index] bkgName]];
            }
            else
            {
                //这里加载的是修改过的图片
                self.bkgImageView.image = image;
            }
        }
    }
    else
    {
        //自定义设置图片取色不可用
    }
    
}

#pragma mark - 设置导航栏的按钮
- (void)setNaviBarItemButton{
    
    UILabel *titleView = [[UILabel alloc]init];
    [titleView setText:self.furnitureName];
    titleView.frame = CGRectMake(0, 0, 100, 16);
    titleView.font = [UIFont systemFontOfSize:16];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"ct_icon_leftbutton"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftButton addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)rightButtonClick:(id)sender
{
}

- (void)leftBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
