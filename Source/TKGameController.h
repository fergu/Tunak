//
//  TKMusicController.h
//  Tunak
//
//  Created by Kevin Ferguson on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TKMusicController : NSObject 
{
	//The music player
	MPMusicPlayerController *musicController;
	
	//Song State
	NSTimeInterval songTimestamp;
	
	//Values
	NSInteger countdownTime;
	float remainingRoundTime;
	
	//The correct items
	NSMutableArray *mediaItems;
	MPMediaItem *correctItem;
	
	//Interface Elements
	UIAlertView *loadingAlertView;
	
	//State
	NSUInteger currentStatus;
}

-(void)startPlaying;
-(void)stopPlaying;
-(void)suspend;
-(void)unsuspend;

-(void)initializeController;
-(void)beginPlay;
-(void)endRound;
-(void)makeGuessWithMediaItem:(MPMediaItem *)mediaItem;

@property (nonatomic, readonly) NSMutableArray *mediaItems;
@property (nonatomic, readonly) MPMediaItem *correctItem;
@property (nonatomic, readonly) NSInteger countdownTime;
@property (nonatomic, readonly) float remainingRoundTime;

@property (nonatomic) NSUInteger currentStatus;
@end

@interface TKScoreController : NSObject 
{
	//State
	NSUInteger currentStatus;
	NSUInteger gameMode;
	
	//State names
	NSString *scoreSuffix;
	
	//Score Variables
	NSUInteger totalScore; //The score (in points) for this game
	NSUInteger highScore; //The high score for this gametype
	NSUInteger roundScore; //The number of points remaining for this round
	
	NSUInteger totalCorrect; //The total number of correct guesses for this game
	NSUInteger totalGuesses; //The total number of guesses for this game
	
	NSUInteger totalAccuracy; //The accuracy of guessing for this game, computed as (totalCorrect * 100) / (totalCorrect + totalGuesses)
	
	NSUInteger totalRounds; //A count of the total number of rounds that have been run
}

-(NSUInteger)loadHighScore;
-(BOOL)saveHighScore;
-(void)initializeController;

-(void)setControllerStatus:(TKMusicController *)controller forResponse:(NSInteger)response;

@property (nonatomic) NSUInteger currentStatus;
@property (nonatomic) NSUInteger gameMode;

@property (nonatomic, retain) NSString *scoreSuffix;
@property (nonatomic, assign) NSUInteger totalScore, highScore, roundScore, totalCorrect, totalGuesses, totalAccuracy, totalRounds;
@end