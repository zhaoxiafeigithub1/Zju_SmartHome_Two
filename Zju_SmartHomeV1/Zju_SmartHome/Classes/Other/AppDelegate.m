//
//  AppDelegate.m
//  Zju_SmartHome
//
//  Created by 123 on 15/10/31.
//  Copyright © 2015年 GJY. All rights reserved.
//

#import "AppDelegate.h"
#import "JYLoginViewController.h"
#import "CYFMainViewController.h"
#import "JYUserData.h"
#import "JYNavigationController.h"
#import <SMS_SDK/SMSSDK.h>
#import "DLLeftSlideMenuViewController.h"
#import "RESideMenu.h"
#import "CYFFurnitureViewController.h"
#import "STNewfeatureController.h"
#define appKey @"c879b326344c"
#define appSecret @"82810facbfba262d63c14ed5dcc5998c"


#import "DLLampControlRGBModeViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    //初始化应用，appKey和appSecret从后台申请得到
   [SMSSDK registerApp:appKey withSecret:appSecret];
    
    //1.先判断有无存储账号信息
//    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *file=[doc stringByAppendingPathComponent:@"account.data"];
//    JYUserData *data=[NSKeyedUnarchiver unarchiveObjectWithFile:file];
   
//    if(data)//已经登录过
//    {
//        
//        DLLeftSlideMenuViewController *leftSlideMenuViewController = [[DLLeftSlideMenuViewController alloc] init];
//        CYFMainViewController *cyfVc=[[CYFMainViewController alloc]init];
//        JYNavigationController *navVc=[[JYNavigationController alloc]initWithRootViewController:cyfVc];
//        RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navVc
//                                                                        leftMenuViewController:leftSlideMenuViewController
//                                                                       rightMenuViewController:nil];
//        self.window.rootViewController=sideMenuViewController;
//        
//    }
//    else//还未登录过
    //{
    
   // JYLoginViewController *jyVc=[[JYLoginViewController alloc]init];
   // JYNavigationController *navVc=[[JYNavigationController alloc]initWithRootViewController:jyVc];
    //self.window.rootViewController=navVc;
    NSString *key = @"CFBundleVersion";
    
    //取出沙盒中存储的上次使用软件的版本号
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *lastVersion=[defaults stringForKey:key];
    
    //获得当前软件的版本号
    NSString *currentVersion=[NSBundle mainBundle].infoDictionary[key];
    
    if ([currentVersion isEqualToString:lastVersion]) {
        //显示状态栏
        application.statusBarHidden=NO;
        self.window.rootViewController=[[JYLoginViewController alloc]init];
    }else{//新版本
        self.window.rootViewController=[[STNewfeatureController alloc]init];
        
        //存储新版本
        [defaults setObject:currentVersion forKey:key];
        [defaults synchronize];
    }

    //self.window.rootViewController=[[DLLampControlRGBModeViewController alloc]init];
    //}
    
    
    application.statusBarStyle=UIStatusBarStyleLightContent;
    [self.window makeKeyAndVisible];
    
    //显示状态栏
    application.statusBarHidden=NO;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.FK.GJY.Zju_SmartHome" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Zju_SmartHome" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Zju_SmartHome.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
