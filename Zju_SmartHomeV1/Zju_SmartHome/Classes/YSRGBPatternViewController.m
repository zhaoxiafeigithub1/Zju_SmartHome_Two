//
//  YSRGBPatternViewController.m
//  Zju_SmartHome
//
//  Created by lysongzi on 15/12/30.
//  Copyright © 2015年 GJY. All rights reserved.
//

#import "YSRGBPatternViewController.h"
#import "YSProductViewController.h"
#import "YSNewPattern.h"
#import "JYNewSqlite.h"
#import "DLLampControlRGBModeViewController.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "JYChangePatternBGController.h"
#import "LYSImageStore.h"

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
//模式切换
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *patterns;
@property (strong, nonatomic) NSMutableArray *cellsView;

@property (assign) NSInteger cellWidth;
@property (assign) NSInteger cellHeight;


//记录当前居中的模式索引
@property (assign) NSInteger selectedIndex;
//定义JYSqlite对象
@property(nonatomic,strong)JYNewSqlite *jynewSqlite;


//有关照片切换背景图的属性；
@property (nonatomic,strong) UIPopoverController *imagePickerPopover;
@property (nonatomic,strong) UIAlertController *alert;

@property(nonatomic,copy)NSString *tableName;

@end

@implementation YSRGBPatternViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"gujinyue %@ %@",self.furnitureName,self.logic_id);
    self.tableName=[NSString stringWithFormat:@"%@%@",self.furnitureName,self.logic_id];
    NSLog(@"我先看看表的名字:%@",self.tableName);
    [self setNaviBarItemButton];
    
    self.cellWidth = UISCREEN_WIDTH / CELL_NUMBER;
    self.cellHeight = self.scrollView.frame.size.height;
    
    [self.pictureButton setBackgroundImage:[UIImage imageNamed:@"zhaopianquse_icon_press"] forState:UIControlStateHighlighted];
    [self.musicButton setBackgroundImage:[UIImage imageNamed:@"music_icon_press"] forState:UIControlStateHighlighted];
    
    //初始化默认模型数据
    [self initPatternData];
    //初始化scrollView
    [self initScrollView];

}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"按返回按钮走这个方法了吧");
    if(self.tag_Back==2)
    {
        NSLog(@"这里应该是从自定义模式返回的哦");
        //初始化默认模型数据
        [self initPatternData];
        //初始化scrollView
        [self initScrollView];
        
        //定位到新添加的模式
        [self.scrollView setContentOffset:CGPointMake(self.cellWidth * (self.patterns.count - 2), 0)];
        //设置当前居中为新添加的模式，并更新背景和文字
        self.selectedIndex = self.patterns.count - 2;
        [self updateCellBackground:(int)self.selectedIndex];
        self.tag_Back = 0;
    }
    else
    {
        NSLog(@"这里应该是修改模式背景图片返回来的");
    }
    
}

//初始化模式的数据
- (void)initPatternData
{
    NSLog(@"初始化模式的数据");
    //初始化
    JYNewSqlite *jynewSqlite=[[JYNewSqlite alloc]init];
    jynewSqlite.patterns=[[NSMutableArray alloc]init];
    self.jynewSqlite=jynewSqlite;
    
    //打开数据库
    [self.jynewSqlite openDB];
    //创建表（如果已经存在时不会再创建的）
    //[self.jynewSqlite createTable];
    [self.jynewSqlite createTable:self.tableName];
    
    //获取表中所有记录
    //[self.jynewSqlite getAllRecord];
    [self.jynewSqlite getAllRecordFromTable:self.tableName];
    
    //self.patterns=jySqlite.patterns;
    if(self.jynewSqlite.patterns.count == 0)
    {
        NSLog(@"暂时还没有数据");
        //柔和模式
//        [self.jynewSqlite insertRecordIntoTableName:@"patternTable" withField1:@"name" field1Value:@"柔和" andField2:@"logoName" field2Value:@"rouhe_icon" andField3:@"bkgName" field3Value:@"rouhe_bg" andField4:@"rValue" field4Value:@"255" andField5:@"gValue" field5Value:@"254" andField6:@"bValue" field6Value:@"253"];
//
        [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"柔和" andField2:@"logoName" field2Value:@"rouhe_icon" andField3:@"bkgName" field3Value:@"rouhe_bg" andField4:@"rValue" field4Value:@"255" andField5:@"gValue" field5Value:@"254" andField6:@"bValue" field6Value:@"253"];
        

        //舒适模式
        [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"舒适" andField2:@"logoName" field2Value:@"shushi_icon" andField3:@"bkgName" field3Value:@"shushi_bg" andField4:@"rValue" field4Value:@"233" andField5:@"gValue" field5Value:@"234" andField6:@"bValue" field6Value:@"235"];
        
        //明亮模式
         [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"明亮" andField2:@"logoName" field2Value:@"mingliang_icon" andField3:@"bkgName" field3Value:@"mingliang_bg" andField4:@"rValue" field4Value:@"100" andField5:@"gValue" field5Value:@"101" andField6:@"bValue" field6Value:@"102"];
      
        //跳跃模式
         [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"跳跃" andField2:@"logoName" field2Value:@"tiaoyue_icon" andField3:@"bkgName" field3Value:@"tiaoyue_bg" andField4:@"rValue" field4Value:@"1" andField5:@"gValue" field5Value:@"2" andField6:@"bValue" field6Value:@"3"];
     
        //R模式
        [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"R" andField2:@"logoName" field2Value:@"R" andField3:@"bkgName" field3Value:@"R_bg" andField4:@"rValue" field4Value:@"255" andField5:@"gValue" field5Value:@"0" andField6:@"bValue" field6Value:@"0"];
        
        //G模式
         [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"G" andField2:@"logoName" field2Value:@"G" andField3:@"bkgName" field3Value:@"G_bg" andField4:@"rValue" field4Value:@"0" andField5:@"gValue" field5Value:@"255" andField6:@"bValue" field6Value:@"0"];
      
        //B模式
         [self.jynewSqlite insertRecordIntoTableName:self.tableName withField1:@"name" field1Value:@"B" andField2:@"logoName" field2Value:@"B" andField3:@"bkgName" field3Value:@"B_bg" andField4:@"rValue" field4Value:@"0" andField5:@"gValue" field5Value:@"0" andField6:@"bValue" field6Value:@"255"];
        
        
        //[self.jynewSqlite getAllRecord];
        [self.jynewSqlite getAllRecordFromTable:self.tableName];
        self.patterns=self.jynewSqlite.patterns;
        NSLog(@"长度%ld",self.patterns.count);
    }
    else
    {
        NSLog(@"已经有数据了");
        self.patterns=self.jynewSqlite.patterns;
        //NSLog(@"长度%ld",self.patterns.count);
    }
    
    //最后一个自定义按钮
    [self.patterns addObject:[[YSNewPattern alloc] initWithName:@"自定义" logoName:@"zidingyi"]];
}

//初始化scrollView的内容
- (void)initScrollView
{
    NSLog(@"初始化ScrollView");
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
        [self.navigationController pushViewController:rgbVc animated:YES];
        
    }
    
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
    NSLog(@"向上滑动删除函数进来了");
    UIView *view = (UIView *)gr.self.view;
    
    //想删除的不是居中的元素，或者默认模式不允许删除，或者是添加按钮键
    if (view.tag != self.selectedIndex || self.selectedIndex < DEFAULT_CELL_NUMBER || view.tag == self.patterns.count - 1)
    {
        return;
    }
    
    YSNewPattern *pattern=[self.patterns objectAtIndex:view.tag];
    //从模型中删除
    [self.patterns removeObjectAtIndex:view.tag];
    
    [self.cellsView[view.tag] setHidden:YES];
    
    NSLog(@"%ld %ld", view.tag, self.cellsView.count);
    
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
        [UIView commitAnimations];
    }
    
    //移除该cell的视图
    [self.cellsView removeObjectAtIndex:view.tag];
    //更新背景和文字
    [self updateCellBackground:(int)view.tag];
    
    //[self.jynewSqlite deleteRecordWithName:pattern.name];
    [self.jynewSqlite deleteRecordWithName:pattern.name inTable:self.tableName];
    
}

//点击图片取色按钮的响应事件
- (IBAction)pictureClick:(id)sender
{
    NSLog(@"图片选择");
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
            JYChangePatternBGController *showPhoto = [[JYChangePatternBGController alloc] init];
            showPhoto.openType = UIImagePickerControllerSourceTypeCamera;//从照相机打开；
            showPhoto.delegate=self;
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
            JYChangePatternBGController *showPhoto = [[JYChangePatternBGController alloc] init];
            showPhoto.logic_id=self.logic_id;
            showPhoto.openType = UIImagePickerControllerSourceTypePhotoLibrary;//从图库打开；
            showPhoto.delegate=self;
            [self.navigationController pushViewController:showPhoto animated:true];
        }
    }]];
    
    [self.alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //取消；
    }]];
    
    //弹出提示框；
    [self presentViewController:self.alert animated:true completion:nil];
}
//修改背景图片的代理方法
-(void)changBG:(UIImage *)image
{
    NSLog(@"回来修改背景图片了吧");
    
    //为新图片创建一个标示文件名的值
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *imageName = [uuid UUIDString];
    
    //接下来存储改文件到本地，以及更新模型的数据
    YSNewPattern *pattern = self.patterns[self.selectedIndex];
    pattern.bkgName = imageName;
    NSLog(@"%@ %@ %@",pattern.name, pattern.bkgName, imageName);
    [[LYSImageStore sharedStore] setImage:image forKey:imageName];
    
    //[self.jynewSqlite updateRecordBKGImage:pattern.name andNewBKGImage:imageName];
    [self.jynewSqlite updateRecordBKGImage:pattern.name andNewBKGImage:imageName inTable:self.tableName];
    
    //这里显示图片
    [self updateCellBackground:(int)self.selectedIndex];
}
//点击播放音乐的响应事件
- (IBAction)musicClick:(id)sender
{
    NSLog(@"音乐选择");
}

#pragma mark - scrollView中cell的动态操作

- (void)addPatternToScrollView:(YSNewPattern *)pattern
{
    //先把该模式添加到数组中
    [self.patterns insertObject:pattern atIndex:self.patterns.count];
    
    //然后添加到scrollView中
    //待定
}

- (void)deletePatternFromScrollView:(YSNewPattern *)pattern
{
    //从模型中删除
    [self.patterns removeObjectAtIndex:self.selectedIndex];
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
        YSNewPattern *pattern=self.patterns[0];
        NSLog(@"lllssdsdds %@,%@,%@",pattern.name,pattern.rValue,pattern.bValue);
        NSString *r = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.rValue intValue]]];
        NSString *g = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.gValue intValue]]];
        
        NSString *b = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.bValue intValue]]];
        
        // NSLog(@"---- %@ %@ %@ %@",self.logic_id,r,g,b);
        
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                      NSLog(@"成功: %@", string);
                                      
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      
                                      [MBProgressHUD showError:@"请检查网关"];
                                      
                                  }];
    }
}

//滑动的时候就会调用的函数，在这里写动画？
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f", self.scrollView.contentOffset.x);
    
    //处理每一个cell，计算它的缩放比例
    for (int i = 0; i < self.cellsView.count; i++)
    {
        float lead = self.cellWidth * (i + 2);
        float tail = self.cellWidth * (i + 3);
        
        //在屏幕左侧
        if (self.scrollView.contentOffset.x > tail)
        {
            [self viewToScale:0.5 target:self.cellsView[i]];
        }
        //在屏幕右侧
        else if ((self.scrollView.contentOffset.x + UISCREEN_WIDTH) < lead)
        {
            [self viewToScale:0.5 target:self.cellsView[i]];
        }
        //现在在界面上
        else
        {
            float sub = lead - self.scrollView.contentOffset.x;
            //前半部分
            if (sub <= 2 * self.cellWidth)
            {
                float rate = sub / (2 * self.cellWidth) * 0.5 + 0.5;
                rate = rate > 1.0 ? 1.0 : rate;
                NSLog(@"%f", rate);
                [self viewToScale:rate target:self.cellsView[i]];
            }
            else
            {
                float rate = (UISCREEN_WIDTH - sub - self.cellWidth) / (2 * self.cellWidth) * 0.5 + 0.5;
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
    //[self openGesture];
    [self.scrollView setUserInteractionEnabled:YES];
    
    YSNewPattern *pattern=self.patterns[(int)self.selectedIndex];
   // NSLog(@"我看看划到的是哪个模式:%@ %@ %@ %@,这里进行灯的控制请求",pattern.name,pattern.rValue,pattern.gValue,pattern.bValue);
    
    NSString *r = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.rValue intValue]]];
    NSString *g = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.gValue intValue]]];
    
    NSString *b = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[pattern.bValue intValue]]];
    
   // NSLog(@"---- %@ %@ %@ %@",self.logic_id,r,g,b);
    if([pattern.name isEqualToString:@"自定义"])
    {
        
    }
    else
    {
        [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                      NSLog(@"成功: %@", string);
                                      
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      
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
    //[self updateCellBackground:index];
}

//滑动到某个cell时更新视图的方法
- (void)updateCellBackground:(int)index
{
    NSLog(@"sleectt  %ld", (long)self.selectedIndex);
    self.patternNameLabel.text = [self.patterns[index] name];
    
    //如果是添加模式按钮则不修改图片
    if (index != self.patterns.count - 1)
    {
        //为默认模式，家在默认图片
        if (self.selectedIndex < DEFAULT_CELL_NUMBER)
        {
            self.bkgImageView.image = [UIImage imageNamed:[self.patterns[index] bkgName]];
        }
        //自定义图片加载自定义模式
        else
        {
            YSNewPattern * selectedPattern = self.patterns[self.selectedIndex];
            UIImage *image = [[LYSImageStore sharedStore] imageForKey:selectedPattern.bkgName];
            
            if (!image)
            {
                self.bkgImageView.image = [UIImage imageNamed:[self.patterns[index] bkgName]];
            }
            else
            {
                self.bkgImageView.image = image;
            }
        }
    }
    
}

#pragma mark - 设置导航栏的按钮
- (void)setNaviBarItemButton{
    
    UILabel *titleView = [[UILabel alloc]init];
    //[titleView setText:@"RGB"];
    [titleView setText:self.furnitureName];
    titleView.frame = CGRectMake(0, 0, 100, 16);
    titleView.font = [UIFont systemFontOfSize:16];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    
    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setImage:[UIImage imageNamed:@"ct_icon_switch-unpress"] forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    rightButton.tag = 1;
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"ct_icon_leftbutton"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftButton addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)rightButtonClick:(id)sender
{
    //0表示为关灯状态，1表示开灯状态
    UIButton *swichButton = (UIButton *)sender;
    //NSLog(@"%ld", swichButton.tag);
    
    //关灯变开灯
    if (!swichButton.tag)
    {
        swichButton.tag = 1;
        [swichButton setImage:[UIImage imageNamed:@"ct_icon_switch-unpress"] forState:UIControlStateNormal];
        //[swichButton setImage:[UIImage imageNamed:@"ct_icon_switch-press"]];
    }
    //开灯变关灯
    else
    {
        swichButton.tag = 0;
        [swichButton setImage:[UIImage imageNamed:@"ct_icon_switch-press"] forState:UIControlStateNormal];
        //[swichButton setImage:[UIImage imageNamed:@"ct_icon_switch-unpress"]];
    }
}

- (void)leftBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
