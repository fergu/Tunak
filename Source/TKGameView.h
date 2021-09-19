//
//  TKGameView.h
//  Tunak 2
//
//  Created by Kevin Ferguson on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <iAd/iAd.h>

@class TKStatusCell;
@class TKSongCell;

@class TKMusicController;
@class TKScoreController;

@interface TKGameView : UIViewController <UIAlertViewDelegate> 
{	
	//Controllers
	TKMusicController *musicController;
	TKScoreController *scoreController;
	
	//Game Status Variables
	NSInteger currentStatus; //The current status of the game. 00 is loading, 01 is countdown, 02 is playing, 03 is correct answer, 04 is incorrect answer, 05 is no answer
	NSInteger gameMode; //The current game mode. 10 is Points, 11 is Accuracy, 12 is Endurance
	
	//IBOutlets
	IBOutlet UITableView *currentStatusTableView;
	IBOutlet UIProgressView *progressIndicator;
	IBOutlet TKSongCell *songCell;
	IBOutlet ADBannerView *adBanner;
	IBOutlet UIToolbar *statusBar;
	
	//Interface Elements
	TKStatusCell *statusCell;
	UIAlertView *statusAlertView;
	TKSongCell *guessedCell;
	
	//Arrays
	NSMutableArray *songCells; //Array to hold the song controllers that populate the table view cells
}

-(id)initForDeviceType:(UIDevice *)device;

-(void)updateStatus:(BOOL)complete;

-(void)pause;
-(void)resume;

-(IBAction)suspend;
-(void)unsuspend;

-(void)endGame;
-(void)initializeController;

@property (assign) NSInteger gameMode;
@property (readonly) NSInteger currentStatus;
@property (nonatomic, retain) IBOutlet TKSongCell *songCell;
@property (nonatomic, retain) IBOutlet TKStatusCell *statusCell;

@end
