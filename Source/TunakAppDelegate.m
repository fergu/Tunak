//
//  TunakAppDelegate.m
//  Tunak
//
//  Created by Kevin Ferguson on 8/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Constants.h"
#import "TunakAppDelegate.h"
#import "TKMainView.h"
#import "TKGameView.h"

@implementation TunakAppDelegate

@synthesize window;
@synthesize viewController, gameController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	self.viewController = [[TKMainView alloc] initForDeviceType:[UIDevice currentDevice]];
	[self.viewController initializeController];
	
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
	if ([self.gameController isKindOfClass:[TKGameView class]])
	{
		if (self.gameController.currentStatus != TK_STATUS_GAMEOVER)
		{
			[self.gameController suspend];
			[[NSUserDefaults standardUserDefaults] setObject:@"InGame" forKey:@"LastStatus"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:@"MainMenu" forKey:@"LastStatus"];
		}
		
	}
	else {
		[self.viewController pause];
		[[NSUserDefaults standardUserDefaults] setObject:@"MainMenu" forKey:@"LastStatus"];
	}		
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LastStatus"] isEqual:@"MainMenu"])
		[self.viewController resume];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setObject:@"Terminated" forKey:@"LastStatus"];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}
@end