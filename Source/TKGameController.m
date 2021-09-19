//
//  TKMusicController.m
//  Tunak
//
//  Created by Kevin Ferguson on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "TKGameController.h"


@implementation TKMusicController
@synthesize mediaItems, correctItem, countdownTime, currentStatus, remainingRoundTime;

-(void)initializeController
{
	musicController = [MPMusicPlayerController applicationMusicPlayer];
	mediaItems = [[NSMutableArray alloc] init];
	
	if (musicController.volume < 0.1) musicController.volume = 0.5;
}

#pragma mark Getters/Setters
-(void)setCurrentStatus:(NSUInteger)newStatus
{
	currentStatus = newStatus;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TK_STATUS_CHANGED" object:self];
}

#pragma mark Public
-(void)startPlaying
{
	self.currentStatus = TK_STATUS_PREPARED;
	
	[self performSelector:@selector(cleanupAndPrepareToLoad)];
}

-(void)stopPlaying
{
	if (self.currentStatus != TK_STATUS_GAMEOVER)
		self.currentStatus = TK_STATUS_PAUSED;
	
	[musicController stop];
}

-(void)suspend
{
	if (self.currentStatus == TK_STATUS_PLAYING)
	{
		[musicController pause];
		self.currentStatus = TK_STATUS_SUSPENDED;
	}
	else [self stopPlaying];
}

-(void)unsuspend
{
	if (self.currentStatus == TK_STATUS_SUSPENDED)
	{
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LastStatus"] isEqualToString:@"InGame"])
		{
			[self startPlaying];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastStatus"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			return;
		}
		
		[self beginPlay];
	}
	else [self startPlaying];
}

#pragma mark Song Loading
-(void)cleanupAndPrepareToLoad
{	
	if (self.currentStatus == TK_STATUS_PAUSED || self.currentStatus == TK_STATUS_SUSPENDED)
		return;
	
	self.currentStatus = TK_STATUS_LOADING;
	
	//Reset counters
	remainingRoundTime = TK_ROUND_LENGTH;
	countdownTime = TK_ROUND_COUNTDOWN_TIME;
	
	//Remove items
	[self.mediaItems removeAllObjects];
	
	//Start Loading
	[self performSelectorInBackground:@selector(loadSongs) withObject:nil];
}

-(void)loadSongs
{
	//Create an autorelease pool since this is never called on the main thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MPMediaQuery *_musicQuery = [MPMediaQuery artistsQuery];
	NSArray *_queryItems = [_musicQuery items];
	
	//Get 4 items to play
	while ([mediaItems count] < 4)
	{
		srand([[NSDate date] timeIntervalSinceReferenceDate]);
		int randNumber = rand() % [_queryItems count];
		
		MPMediaItem *_mediaItem = [_queryItems objectAtIndex:randNumber];
		
		if (![mediaItems containsObject:_mediaItem] && [(NSNumber *)[_mediaItem valueForProperty:MPMediaItemPropertyMediaType] intValue] == MPMediaTypeMusic)
			[mediaItems addObject:_mediaItem];
	}
	
	//Choose one of the songs to play
	correctItem = [mediaItems objectAtIndex:rand() % [mediaItems count]];
	NSNumber  *_songToPlayLength = [correctItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
	
	NSArray *itemArray = [[NSArray alloc] initWithObjects:correctItem, nil];
	MPMediaItemCollection *_collection = [MPMediaItemCollection collectionWithItems:itemArray];
	[itemArray release];
	
	NSInteger playbackTime = (rand() % [_songToPlayLength intValue]) - 30;
	
	[musicController setQueueWithItemCollection:_collection];
	[musicController setCurrentPlaybackTime:playbackTime];
		
	if (self.currentStatus != TK_STATUS_LOADING)
		return;
	
	self.currentStatus = TK_STATUS_READY;
	[self performSelectorOnMainThread:@selector(dismissAlertAndStart) withObject:nil waitUntilDone:NO];
	
	//Drain the pool
	[pool drain];
}

-(void)dismissAlertAndStart
{
	self.currentStatus = TK_STATUS_COUNTDOWN;
		
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimerFired:) userInfo:nil repeats:YES];
}

-(void)beginPlay
{
	self.currentStatus = TK_STATUS_PLAYING;
	
	[NSTimer scheduledTimerWithTimeInterval:TK_UPDATE_INTERVAL target:self selector:@selector(roundTimerFired:) userInfo:nil repeats:YES];
	[musicController play];
}

#pragma mark Guessing
-(void)makeGuessWithMediaItem:(MPMediaItem *)mediaItem
{
	//Prevent a guess if we aren't playing
	if (self.currentStatus != TK_STATUS_PLAYING)
		return;
		
	if ([[self.correctItem valueForProperty:MPMediaItemPropertyPersistentID] intValue] == [[mediaItem valueForProperty:MPMediaItemPropertyPersistentID] intValue])
	{
		self.currentStatus = TK_STATUS_CORRECTANSWER;
	}
	else 
	{
		self.currentStatus = TK_STATUS_WRONGANSWER;
	}
	
	[self endRound];
}

-(void)endRound
{
	[musicController stop];
	
	if (currentStatus != TK_STATUS_GAMEOVER)
		[self performSelector:@selector(cleanupAndPrepareToLoad) withObject:nil afterDelay:3.0];
}

#pragma mark Timers
-(void)countdownTimerFired:(NSTimer *)theTimer
{	
	if (currentStatus != TK_STATUS_COUNTDOWN)
	{
		[theTimer invalidate];
		return;
	}
	
	if (countdownTime != 0)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TK_COUNTDOWN_INCREMENT" object:self];
		countdownTime--;
	}
	else
	{
		[theTimer invalidate];
		[self performSelector:@selector(beginPlay)];
	}
}

-(void)roundTimerFired:(NSTimer *)theTimer
{
	if (self.currentStatus != TK_STATUS_PLAYING)
	{
		[theTimer invalidate];
		return;
	}
	
	if (remainingRoundTime != 0)
	{
		remainingRoundTime = remainingRoundTime-TK_UPDATE_INTERVAL;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TK_ROUNDTIME_INCREMENT" object:self];
	}
	else if (remainingRoundTime <= 0)
	{	
		[theTimer invalidate];
		
		self.currentStatus = TK_STATUS_NOANSWER;
		[self endRound];
	}
}

#pragma mark Memory Management
-(void)dealloc
{
	[self.mediaItems removeAllObjects];
	[mediaItems release];
	[super dealloc];
}

@end

#pragma mark -
@implementation TKScoreController
@synthesize currentStatus, gameMode, totalScore, highScore, roundScore, totalCorrect, totalGuesses, totalAccuracy, totalRounds, scoreSuffix;

-(void)initializeController
{
	totalScore = 0; roundScore = 0; highScore = 0;
	totalCorrect = 0; totalGuesses = 0;
	totalAccuracy = 0; totalRounds = 0;
	
	switch (self.gameMode) {
		case TK_MODE_POINTS:
			self.scoreSuffix = @"points";
			break;
		case TK_MODE_ACCURACY:
			self.scoreSuffix = @"songs";
			break;
		case TK_MODE_ENDURANCE:
			self.scoreSuffix = @"points";
			break;
		default:
			break;
	}
	
	self.highScore = [self loadHighScore];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentStatusChanged:) name:@"TK_STATUS_CHANGED" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roundTimerIncrement) name:@"TK_ROUNDTIME_INCREMENT" object:nil];
}

#pragma mark Notifcation Selectors
-(void)currentStatusChanged:(NSNotification *)notification
{
	TKMusicController *controller = [notification object];
	
	self.currentStatus = controller.currentStatus;
	
	switch (currentStatus) 
	{
		case TK_STATUS_READY:
		{
			self.roundScore = TK_MAX_ROUND_SCORE;
			break;
		}
		case TK_STATUS_CORRECTANSWER:
		{
			self.totalGuesses++;
			self.totalCorrect++;
			self.totalAccuracy = (self.totalCorrect * 100)/(self.totalGuesses);
			self.totalRounds++;
			
			self.totalScore = self.totalScore + self.roundScore;
			
			break;
		}
		case TK_STATUS_WRONGANSWER:
		{
			self.totalGuesses++;
			self.totalAccuracy = (self.totalCorrect * 100)/(self.totalGuesses);
			self.totalRounds++;			
			break;
		}
		case TK_STATUS_NOANSWER:
		{
			self.totalGuesses++;
			self.totalAccuracy = (self.totalCorrect * 100)/(self.totalGuesses);
			self.totalRounds++;			
			break;
		}
		default:
			break;
	}	
}

-(void)roundTimerIncrement
{
	if (self.gameMode != TK_MODE_ACCURACY)
		self.roundScore = self.roundScore - TK_SCORE_INCREMENT;
	else self.roundScore = 1;
}

-(void)setControllerStatus:(TKMusicController *)controller forResponse:(NSInteger)response
{
	if (self.gameMode == TK_MODE_ACCURACY && response != TK_STATUS_CORRECTANSWER && response != TK_STATUS_PAUSED)
	{
		controller.currentStatus = TK_STATUS_GAMEOVER;
		return;
	}
	
	if (self.totalRounds == TK_ROUNDS_MAX && self.gameMode == TK_MODE_POINTS)
	{
		controller.currentStatus = TK_STATUS_GAMEOVER;
		return;
	}
}

#pragma mark High Score
-(NSUInteger)loadHighScore
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *_keyName = @"";
	switch (self.gameMode) 
	{
		case TK_MODE_POINTS:
			_keyName = @"highScoreKey";
			break;
		case TK_MODE_ACCURACY:
			_keyName = @"accuracyKey";
			break;
		case TK_MODE_ENDURANCE:
			_keyName = @"enduranceKey";
			break;
		default:
			break;
	}
	
	NSUInteger score = [defaults integerForKey:_keyName];
	
	return score;
}

-(BOOL)saveHighScore
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *_keyName = @"";
	switch (self.gameMode) 
	{
		case TK_MODE_POINTS:
			_keyName = @"highScoreKey";
			break;
		case TK_MODE_ACCURACY:
			_keyName = @"accuracyKey";
			break;
		case TK_MODE_ENDURANCE:
			_keyName = @"enduranceKey";
			break;
		default:
			break;
	}
	
	NSUInteger oldScore = [self loadHighScore];
		
	if (self.totalScore > oldScore)
	{
		[defaults setInteger:self.totalScore forKey:_keyName];
		[defaults synchronize];
		return YES;
	}
	
	return NO;
}

#pragma mark Memory Management
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.scoreSuffix = nil;
	
	[super dealloc];
}

@end