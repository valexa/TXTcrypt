//
//  TXTcryptAppDelegate.m
//  TXTcrypt
//
//  Created by Vlad Alexa on 6/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TXTcryptAppDelegate.h"

@implementation TXTcryptAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
	
	//alloc defaults
	defaults = [NSUserDefaults standardUserDefaults];	
	if ([defaults objectForKey:@"clearData"] == nil) [defaults setBool:YES forKey:@"clearData"];
	[defaults setBool:NO forKey:@"confirmPass"];	
	[defaults synchronize];
	
	// Set the style to black so it matches the background of the application
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	// Now show the status bar
	[application setStatusBarHidden:NO];	
	    
    // Override point for customization after application launch	
	window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	controller = [[TXTcryptViewController alloc] init];
    window.rootViewController = controller;
	//[window addSubview:[controller view]]; //not needed anymore?
	//bug with 320x480
	controller.view.frame = [UIScreen mainScreen].applicationFrame;
	[window makeKeyAndVisible];		
	
	//alloc user promts and save run count
	promts = [[UserPrompts alloc] initWithAppID:319577875 delegate:controller];	
	
	return YES;
	
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [controller.txtView setText:[[url description] substringFromIndex:11]];
    return YES;
}

- (void)dealloc {
    [promts release];
	[window release];
	[controller release];
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	if ([defaults boolForKey:@"clearData"] == YES) {
		controller.txtView.text = @"";
		controller.passView.text = @"";		
        controller.txtlbl.text = @"(0 characters)"; 		
	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [promts incrementRunCount];    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


@end
