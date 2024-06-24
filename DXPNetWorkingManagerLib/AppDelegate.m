//
//  AppDelegate.m
//  DXPNetWorkingManagerLib
//
//  Created by 李标 on 2024/6/23.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	self.window.backgroundColor = [UIColor whiteColor];
	
	ViewController *vc = [[ViewController alloc] init];
	self.window.rootViewController = vc;
	
	
	[application delegate].window = self.window;
	[self.window makeKeyAndVisible];
	
	return YES;
}


@end
