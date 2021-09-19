//
//  TunakAppDelegate.h
//  Tunak
//
//  Created by Kevin Ferguson on 8/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKMainView;
@class TKGameView;
@interface TunakAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TKMainView *viewController;
	TKGameView *gameController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) TKMainView *viewController;
@property (nonatomic, retain) TKGameView *gameController;
@end