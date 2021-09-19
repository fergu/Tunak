//
//  TKMainView.h
//  Tunak 2
//
//  Created by Kevin Ferguson on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface TKMainView : UIViewController
{		
	//Text Views
	IBOutlet UITextView *highScoreText, *accuracyText, *enduranceText;
	
	//Initialization
	BOOL initialized;
	BOOL running;
	
	AVPlayer *audioPlayer;
	
	//Album art images
	IBOutlet UIImageView *imageView1, *imageView2, *imageView3, *imageView4;
	NSArray *albumImageArray; //Holds a list of image views that rotate using different album art
	
	//Picker Scroll View
	IBOutlet UIScrollView *modePickerScroller;
	IBOutlet UIPageControl *pageController;
	
	NSTimer *imageSwitchTimer; //The timer controlling when an image switches
	NSTimer *songSwitchTimer;
	
	float maxMusicVolume;
}

-(id)initForDeviceType:(UIDevice *)device;
-(void)initializeController;

-(IBAction)beginHighScore;
-(IBAction)beginEndurance;
-(IBAction)beginAccuracy;

-(void)pause;
-(void)resume;
-(BOOL)canRun;

-(void)loadSong;
@property (nonatomic, retain) AVPlayer *audioPlayer;
@end
