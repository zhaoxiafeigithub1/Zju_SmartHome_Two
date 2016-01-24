//
//  STUserInfoController.m
//  个人信息demo
//
//  Created by 123 on 16/1/8.
//  Copyright © 2016年 HST. All rights reserved.
//

#import "STEditSceneController.h"
#import "STEditSceneView.h"
#import "STEditSceneCell.h"
#import "UIImage+ST.h"
#import "YSScene.h"
#import "STNewSceneCell.h"
#import "AFNetworking.h"
#import "JYFurniture.h"
#import "JYSceneSqlite.h"
#import "MBProgressHUD+MJ.h"
#import "DLLampControlRGBModeViewController.h"
#import "DLLampControllYWModeViewController.h"
#import "AppDelegate.h"
#import "YSSceneViewController.h"
@interface STEditSceneController ()<UITableViewDataSource,UITableViewDelegate,STEditSceneViewDelegate,DLLampControlRGBModeViewDelegate,DLLampControllYWModeViewDelegate>
@property(nonatomic,strong)STEditSceneView *editSceneView;
@property(nonatomic,strong)NSArray *iconArray;
@property(nonatomic,strong)NSArray *deviceArray;

@property(nonatomic,copy)NSString *tableName;

@property(nonatomic,assign)int count;
@end

@implementation STEditSceneController

-(NSArray *)iconArray
{
    if (_iconArray==nil) {
        NSArray *iconArr=[NSArray arrayWithObjects:@"changjing_edit_icon_yw", @"changjing_edit_icon_rgb",@"changjing_edit_icon_music",@"changjing_edit_icon_ac",nil];
        _iconArray=iconArr;
    }
    return _iconArray;
}
//-(NSArray *)deviceArray
//{
//    if (_deviceArray==nil) {
//        NSArray *deviceArr=[NSArray arrayWithObjects:@"YW灯", @"RGB灯",@"音响",@"空调",nil];
//        _deviceArray=deviceArr;
//    }
//    return _deviceArray;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBarItemButton];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.tableName = [NSString stringWithFormat:@"sceneTable%@",appDelegate.user_id];
    NSLog(@"看看表明%@",self.tableName);

    NSLog(@"看看当前场景的区域和名称有没有传递过来:%@ %@",self.area,self.scene_name);
    for(int i=0;i<self.editFurnitureArray.count;i++)
    {
        YSScene *scene=self.editFurnitureArray[i];
        NSLog(@"刚进来:%@ %@ %@ %@ %@ %@ %@",scene.area,scene.name,scene.logic_id,scene.type,scene.param1,scene.param2,scene.param3);
    }
    
    STEditSceneView *editSceneView=[STEditSceneView initWithEditSceneView];
    editSceneView.frame=self.view.bounds;
    
    //用户名
    editSceneView.sceneName.text=self.scene_name;
    
    //头像
    [editSceneView.sceneIcon setImage:[UIImage circleImageWithName:@"头像.jpg" borderWith:0 borderColor:nil]];
    
    //userView的代理
    editSceneView.delegate=self;
    //tableView的代理
    editSceneView.devicesTableView.delegate=self;
    editSceneView.devicesTableView.dataSource=self;
    self.editSceneView=editSceneView;
    [self.view addSubview:editSceneView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.editFurnitureArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID=@"deviceCell";
    STEditSceneCell *deviceCell=[tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取电器
    YSScene *scene = self.editFurnitureArray[indexPath.row];
    
    if (deviceCell==nil)
    {
        deviceCell = [STEditSceneCell initWithEditSceneCell];
        
        //判断设备类型设置图标
        if ([scene.type isEqualToString:@"40"])
        {
            [deviceCell.iconView setImage:[UIImage imageNamed:@"changjing_edit_icon_rgb"]];
        }
        else if ([scene.type isEqualToString:@"41"])
        {
            [deviceCell.iconView setImage:[UIImage imageNamed:@"changjing_edit_icon_yw"]];
        }
        else
        {
            [deviceCell.iconView setImage:[UIImage imageNamed:@"changjing_edit_icon_ac"]];
        }
        for(int i=0;i<self.furnitureArray.count;i++)
        {
            JYFurniture *furniture=self.furnitureArray[i];
            if([furniture.logic_id isEqualToString:scene.logic_id])
            {
                  deviceCell.deviceName.text =furniture.descLabel;
//                  furniture.isNeeded=(int)deviceCell.up_down.tag;
            }
        }
        UIColor *color=[[UIColor alloc]initWithRed:(0/255.0f) green:(0/255.0f) blue:(0/255.0f) alpha:1.0];
        deviceCell.selectedBackgroundView=[[UIView alloc]initWithFrame:deviceCell.frame];
        deviceCell.selectedBackgroundView.backgroundColor=color;
        
       [deviceCell.up_down addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
   return deviceCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat originH=45;
    CGFloat originW=320;
    CGFloat newH=(self.view.frame.size.width*originH)/originW;
    return newH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"怎么点击不了了啊");
    if([self.editSceneView.sceneName.text isEqualToString:@""])
    {
        NSLog(@"请先输入场景名称");
    }
    else
    {
        YSScene *scene=self.editFurnitureArray[indexPath.row];
       
        NSLog(@"这里呢:%@ %@",scene.name,scene.type);
        //说明是RGB灯
        if([scene.type isEqualToString:@"40"])
        {
            NSLog(@"跳转到RGB自定义颜色界面");
            DLLampControlRGBModeViewController *vc=[[DLLampControlRGBModeViewController alloc]init];
            vc.sceneTag=400;
            vc.delegate=self;
            vc.logic_id=scene.logic_id;
            vc.type=scene.type;
            [self.navigationController pushViewController:vc animated:YES];
        }
        //说明是YW灯
        else if([scene.type isEqualToString:@"41"])
        {
            NSLog(@"跳转到YW灯自定义颜色界面");
            DLLampControllYWModeViewController *vc=[[DLLampControllYWModeViewController alloc]init];
            vc.sceneTag=411;
            vc.delegate=self;
            vc.logic_id=scene.logic_id;
            vc.type=scene.type;
            [self.navigationController pushViewController:vc animated:YES];
        }
        //说明是其他
        else
        {
                
        }
    }
}

#pragma mark - 设置导航栏的按钮
- (void)setNaviBarItemButton{
    
    UILabel *titleView = [[UILabel alloc]init];
    [titleView setText:@"编辑场景"];
    titleView.frame = CGRectMake(0, 0, 100, 16);
    titleView.font = [UIFont systemFontOfSize:16];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(rightButtonClick:)];
    rightButton.tintColor = [UIColor whiteColor];
    [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"ct_icon_leftbutton"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftButton addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftItem;
}
- (void)rightButtonClick:(id)sender
{
//    [self saveNewScene:nil];
    NSLog(@"右边保存按钮吧？");
    for(int i=0;i<self.editFurnitureArray.count;i++)
    {
        YSScene *scene=self.editFurnitureArray[i];
        NSLog(@"要保存:%@ %@ %@ %@ %@ %@ %@",scene.area,scene.name,scene.logic_id,scene.type,scene.param1,scene.param2,scene.param3);
    }
    
    self.navigationController.navigationBar.hidden=NO;
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
    NSString *sceneNewName = self.editSceneView.sceneName.text;
    NSLog(@"修改的名字%@",sceneNewName);
    
    int i=0;
    for(i=0;i<self.editFurnitureArray.count;i++)
    {
        YSScene *scene=self.editFurnitureArray[i];
        //1.创建请求管理对象
        AFHTTPRequestOperationManager *mgr=[AFHTTPRequestOperationManager manager];
        
        //2.说明服务器返回的是json参数
        mgr.responseSerializer=[AFJSONResponseSerializer serializer];
        
        //3.封装请求参数
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        //移动端
        params[@"is_app"]=@"1";
        //标志场景
        params[@"sceneconfig.tag"]=@"1";
        //区域
        params[@"sceneconfig.room_name"] = scene.area;
        //场景原先名称
        params[@"sceneconfig.scene_name"] = scene.name;
        //场景新名称
        params[@"sceneconfig.new_scene_name"]=sceneNewName;
        //电器逻辑id
        params[@"sceneconfig.equipment_logic_id"]=scene.logic_id;
        //参数值
        params[@"sceneconfig.param1"] = scene.param1;
        params[@"sceneconfig.param2"] = scene.param2;
        params[@"sceneconfig.param3"] = scene.param3;
        
        NSLog(@"1111 %@ %@ %@ %@ %@ %@ %@ %@ %@ ",scene.area,scene.name,sceneNewName,scene.bkgName,scene.logic_id,scene.type,scene.param1,scene.param2,scene.param3);
        
        //4.发送请求
        [mgr POST:@"http://60.12.220.16:8888/paladin/Sceneconfig/update" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if([responseObject[@"code"] isEqualToString:@"0"])
             {
                 JYSceneSqlite *jySqlite=[[JYSceneSqlite alloc]init];
                 jySqlite.patterns=[[NSMutableArray alloc]init];
                 
                 //打开数据库
                 [jySqlite openDB];
                 
                 [jySqlite updateRecordParamInArea:self.area andInScene:scene.name andInLogicID:scene.logic_id withNewP1:scene.param1 withNewP2:scene.param2 withNewP3:scene.param3 withNewScene:sceneNewName inTable:self.tableName];
                 self.count++;
             }
             else
             {
                 [MBProgressHUD showError:@"修改场景失败"];
             }
             
             if(self.count==self.editFurnitureArray.count)
             {
                 
                 for (UIViewController *controller in self.navigationController.viewControllers)
                 {
                     if ([controller isKindOfClass:[YSSceneViewController class]])
                     {
                         YSSceneViewController *vc=(YSSceneViewController *)controller;
                         vc.tag_Back = 2;
                         
                         [self.navigationController popToViewController:controller animated:YES];
                     }
                 }
             }

         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD showError:@"修改场景失败,请检查服务器"];
         }];
    }

}

- (void)leftBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)switchBtn:(id)sender
{
    UIButton *button=sender;
    
    if(button.tag==0)
    {
        button.tag=-1;
        [button setBackgroundImage:[UIImage imageNamed:@"changjing_edit_btn_equipment_notadded"] forState:UIControlStateNormal];
    }
    else if(button.tag==-1)
    {
        button.tag=0;
        [button setBackgroundImage:[UIImage imageNamed:@"changjing_edit_btn_equipment_added"] forState:UIControlStateNormal];
    }
    
}

//实现RGB灯的代理方法
-(void)backParam:(NSString *)param1 andParam2:(NSString *)param2 andParam3:(NSString *)param3 andLogic_Id:(NSString *)logic_id andType:(NSString *)type
{
    NSLog(@"RGB:%@ %@ %@ %@ %@ %@ %@",self.area,self.editSceneView.sceneName.text,param1,param2,param3,logic_id,type);
    
    for(int i=0;i<self.editFurnitureArray.count;i++)
    {
        YSScene *scene=self.editFurnitureArray[i];
        if([scene.logic_id isEqualToString:logic_id])
        {
            scene.param1=param1;
            scene.param2=param2;
            scene.param3=param3;
        }
    }
}
//实现YW灯的代理方法
-(void)backParamYW:(NSString *)param1 andParam2:(NSString *)param2 andParam3:(NSString *)param3 andLogic_Id:(NSString *)logic_id andType:(NSString *)type
{
    NSLog(@"YW:%@ %@ %@ %@ %@ %@ %@",self.area,self.editSceneView.sceneName.text,param1,param2,param3,logic_id,type);
    
    for(int i=0;i<self.editFurnitureArray.count;i++)
    {
        YSScene *scene=self.editFurnitureArray[i];
        if([scene.logic_id isEqualToString:logic_id])
        {
            scene.param1=param1;
            scene.param2=param2;
            scene.param3=param3;
        }
    }
}
@end
