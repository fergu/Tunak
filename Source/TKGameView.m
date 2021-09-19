//
//  TKPadGameView.m
//  Tunak
//
//  Created by Kevin Ferguson on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "TKGameView.h"

//Selection Views
#import "TKSongCell.h"

//Status View
#import "TKStatusCell.h"

//Controllers
#import "TKGameController.h"

@implementation TKGameView
@synthesize gameMode, currentStatus, songCell, statusCell;

-(id)initForDeviceType:(UIDevice *)device
{
	if (self = [super init])
	{
		UIUserInterfaceIdiom idiom = [device userInterfaceIdiom];
		
		if (idiom == UIUserInterfaceIdiomPhone)
			[[NSBundle mainBundle] loadNibNamed:@"TKPhoneGameView" owner:self options:nil];
		
		if (idiom == UIUserInterfaceIdiomPad)
			[[NSBundle mainBundle] loadNibNamed:@"TKPadGameView" owner:self options:nil];
	}
	return self;
}

#pragma mark View Loading
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[self initializeController];
	[super viewDidAppear:animated];
}

-(void)pause
{
	[musicController stopPlaying];
}

-(void)resume
{
	[musicController startPlaying];
}

-(void)suspend
{
	NSMutableArray *barItems = [statusBar.items mutableCopy];
	while ([barItems count] > 3)
		[barItems removeLastObject];
	
	UIBarButtonItem *quitItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(endGame)];
	quitItem.style = UIBarButtonItemStyleBordered;
	[barItems addObject:quitItem];
	
	UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(unsuspend)];
	newItem.style = UIBarButtonItemStyleBordered;
	[barItems addObject:newItem];
	
	[statusBar setItems:barItems animated:YES];
	[barItems release]; [newItem release]; [quitItem release];
	
	[musicController suspend];
}

-(IBAction)unsuspend
{
	NSMutableArray *barItems = [statusBar.items mutableCopy];
	
	while ([barItems count] > 3) {
		[barItems removeLastObject];
	}
	
	UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(suspend)];
	newItem.style = UIBarButtonItemStyleBordered;
	[barItems addObject:newItem];
	[statusBar setItems:barItems animated:YES];
	
	[barItems release]; [newItem release];
	
	[musicController unsuspend];
}

-(void)endGame
{
	NSString *_message = @"";
	
	switch (self.gameMode) 
	{
		case TK_MODE_POINTS:
		{
			_message = [NSString stringWithFormat:@"Final Score: %d points\n%d%% accuracy", scoreController.totalScore, (scoreController.totalCorrect * 100) / (scoreController.totalGuesses)];
			
			if ([scoreController saveHighScore])
				_message = [_message stringByAppendingString:@"\nNew high score!"];
			
			break;
		}
		case TK_MODE_ACCURACY:
		{
			_message = [NSString stringWithFormat:@"Final Score: %d songs", scoreController.totalCorrect];
			if (scoreController.totalCorrect == 1)
				_message = [NSString stringWithFormat:@"Final Score: %d song", scoreController.totalCorrect];
			
			if ([scoreController saveHighScore])
				_message = [_message stringByAppendingString:@"\nNew high score!"];
			
			break;
		}
		case TK_MODE_ENDURANCE:
		{
			_message = [NSString stringWithFormat:@"Final Score: %d points\n%d songs correct\n%d%% accuracy", scoreController.totalScore, scoreController.totalCorrect, (scoreController.totalCorrect * 100) / (scoreController.totalGuesses)];
			
			if ([scoreController saveHighScore])
				_message = [_message stringByAppendingString:@"\nNew high score!"];
			break;
		}
		default:
			break;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:_message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark Initialization
-(void)initializeController
{
	if (!musicController) musicController = [[TKMusicController alloc] init];
	if (!scoreController) scoreController = [[TKScoreController alloc] init];
	if (!statusCell) statusCell = [[TKStatusCell alloc] init];
	
	scoreController.gameMode = self.gameMode;
	
	[musicController initializeController]; [scoreController initializeController];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentStatusChanged) name:@"TK_STATUS_CHANGED" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countdownTimerIncrement) name:@"TK_COUNTDOWN_INCREMENT" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roundTimerIncrement) name:@"TK_ROUNDTIME_INCREMENT" object:nil];
	[musicController startPlaying];
}

#pragma mark Notifcation Responders
-(void)currentStatusChanged
{
	currentStatus = musicController.currentStatus;	
	switch (currentStatus) {
		case TK_STATUS_LOADING:
		{
			[progressIndicator setProgress:1];
			//statusAlertView = [[UIAlertView alloc] initWithTitle:@"Loading" message:@"Please wait..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
			//[statusAlertView show];
			
			for (TKSongCell *_cell in songCells)
			{
				[_cell setIsLoading];
			}
			
			[self updateStatus:YES];
			
			break;
		}
		case TK_STATUS_READY:
		{			
			int i = 0;
			for (TKSongCell *_cell in songCells)
			{
				_cell.mediaItem = [musicController.mediaItems objectAtIndex:i];
				[_cell configureCell];
				i++;
			}
			break;
		}
		case TK_STATUS_COUNTDOWN:
		{
			//[statusAlertView dismissWithClickedButtonIndex:0 animated:YES];
			//[statusAlertView release];
			break;
		}
		case TK_STATUS_PLAYING:
		{
			[self updateStatus:NO];
			break;
		}
		case TK_STATUS_GAMEOVER:
		{
			[musicController stopPlaying];
			[self endGame];
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			break;
		}
		case TK_STATUS_SUSPENDED:
		{
			[self updateStatus:NO];
			break;
		}
		default:
			break;
	}
	
	if (currentStatus == TK_STATUS_CORRECTANSWER || currentStatus == TK_STATUS_WRONGANSWER || currentStatus == TK_STATUS_NOANSWER || currentStatus == TK_STATUS_PAUSED || currentStatus == TK_STATUS_SUSPENDED)
	{
		[self updateStatus:YES];
		[scoreController setControllerStatus:musicController forResponse:currentStatus];
	}
}

-(void)countdownTimerIncrement
{
	[self updateStatus:NO];
}

-(void)roundTimerIncrement
{
	[progressIndicator setProgress:musicController.remainingRoundTime/TK_ROUND_LENGTH];
}

#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark Status Updating
-(void)updateStatus:(BOOL)complete
{
	if (complete)
	{
		statusCell.totalScoreLabel.text = [NSString stringWithFormat:@"%d %@", scoreController.totalScore, scoreController.scoreSuffix];
		if (self.gameMode == TK_MODE_ACCURACY && scoreController.totalScore == 1)
		{
			statusCell.totalScoreLabel.text = [NSString stringWithFormat:@"%d song", scoreController.totalScore];
		}
		
		statusCell.highScoreLabel.text = [NSString stringWithFormat:@"%d %@", scoreController.highScore, scoreController.scoreSuffix];
		statusCell.correctGuessesLabel.text = [NSString stringWithFormat:@"%d", scoreController.totalCorrect];
		statusCell.totalGuessesLabel.text = [NSString stringWithFormat:@"%d", scoreController.totalGuesses];
		statusCell.averageScoreLabel.text = [NSString stringWithFormat:@"%d", scoreController.totalScore / scoreController.totalCorrect];
		statusCell.accuracyLabel.text = [NSString stringWithFormat:@"%d%%", (scoreController.totalCorrect * 100) / (scoreController.totalGuesses)];
	}
	
	switch (currentStatus) {
		case TK_STATUS_LOADING:
		{
			for (TKSongCell *_cell in songCells)
			{
				[UIView animateWithDuration:0.25 animations:^{
					_cell.backgroundColor = [UIColor clearColor];
					_cell.accessoryType = UITableViewCellAccessoryNone;
				}];
			}
			
			statusCell.statusLabel.text = @"Now Loading. Please wait...";
			if (self.gameMode == TK_MODE_POINTS)
				statusCell.correctAnswerLabel.text = [NSString stringWithFormat:@"Song %d of %d", scoreController.totalGuesses+1, TK_ROUNDS_MAX];
			else statusCell.correctAnswerLabel.text = [NSString stringWithFormat:@"Song %d", scoreController.totalGuesses+1];
			break;
		}
		case TK_STATUS_READY:
		{
			statusCell.statusLabel.text = @"Ready to begin.";
			break;
		}
		case TK_STATUS_COUNTDOWN:
		{
			statusCell.statusLabel.text = [NSString stringWithFormat:@"Get ready. Starting in %d...", musicController.countdownTime];
			break;
		}
		case TK_STATUS_PLAYING:
		{
			statusCell.statusLabel.text = @"Touch the song to make a guess.";
			
			if (self.gameMode == TK_MODE_POINTS)
				statusCell.correctAnswerLabel.text = [NSString stringWithFormat:@"Song %d of %d", scoreController.totalGuesses+1, TK_ROUNDS_MAX];
			else statusCell.correctAnswerLabel.text = [NSString stringWithFormat:@"Song %d", scoreController.totalGuesses+1];
			
			break;
		}
		case TK_STATUS_CORRECTANSWER:
		{
			statusCell.statusLabel.text = [NSString stringWithFormat:@"Correct! +%d", scoreController.roundScore];
			
			for (TKSongCell *_cell in songCells)
			{
				if (_cell.mediaItem == musicController.correctItem)
				{
					[UIView animateWithDuration:0.25 animations:^{
						_cell.backgroundColor = [UIColor greenColor];
						_cell.accessoryType = UITableViewCellAccessoryCheckmark;
						
					}];
				}
			}
			
			break;
		}
		case TK_STATUS_WRONGANSWER:
		{
			statusCell.statusLabel.text = [NSString stringWithFormat:@"Incorrect. +0"];
			statusCell.correctAnswerLabel.text = [NSString stringWithFormat:@"Correct Answer: %@ by %@", 
													  [musicController.correctItem valueForProperty:MPMediaItemPropertyTitle], 
													  [musicController.correctItem valueForProperty:MPMediaItemPropertyArtist]];
			
			for (TKSongCell *_cell in songCells)
			{
				if (_cell.mediaItem == musicController.correctItem)
				{
					[UIView animateWithDuration:0.25 animations:^{
						_cell.backgroundColor = [UIColor greenColor];
						_cell.accessoryType = UITableViewCellAccessoryCheckmark;
					}];
				}
				[UIView animateWithDuration:0.25 animations:^{
					guessedCell.backgroundColor = [UIColor redColor];
				}];
				
				guessedCell = nil;
			} 
			break;
		}
		case TK_STATUS_NOANSWER:
		{
			statusCell.statusLabel.text = @"Out of time. +0";
			break;
		}
		case TK_STATUS_PAUSED:
		{
			statusCell.statusLabel.text = @"Paused.";
			break;
		}
		case TK_STATUS_SUSPENDED:
		{
			statusCell.statusLabel.text = @"Paused.";
			break;
		}
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TK_SONG_CELL"];
	
	if (!songCells) songCells = [[NSMutableArray alloc] init];
	
	if (cell == nil) 
	{
		UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
		
		if (idiom == UIUserInterfaceIdiomPhone)
			[[NSBundle mainBundle] loadNibNamed:@"TKPhoneSongCell" owner:self options:nil];
		if (idiom == UIUserInterfaceIdiomPad)
			[[NSBundle mainBundle] loadNibNamed:@"TKPadSongCell" owner:self options:nil];
		
		cell = songCell;
		self.songCell = nil;		
    }
	if (![songCells containsObject:cell])
	{
		[songCells addObject:cell];
		[(TKSongCell *)cell setIsLoading];
	}
	
    return cell;
}

#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
	
	if (idiom == UIUserInterfaceIdiomPhone)
		return 64;
	if (idiom == UIUserInterfaceIdiomPad)
		return 114;
	
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	TKSongCell *_cell = (TKSongCell *)[tableView cellForRowAtIndexPath:indexPath];
	guessedCell = _cell;
	
	[musicController makeGuessWithMediaItem:_cell.mediaItem];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Ad Management
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	CGRect screen = [self.view frame];
	if (!CGRectEqualToRect(banner.frame, CGRectMake(0, screen.size.height-banner.frame.size.height, screen.size.width, banner.frame.size.height)))
	{
		//Animate the view out
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
		[banner setFrame:CGRectMake(0, screen.size.height-banner.frame.size.height, screen.size.width, banner.frame.size.height)];
		[UIView commitAnimations];
	}
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	if (willLeave)
		[self pause];
	else [self suspend];
	
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	CGRect screen = [self.view frame];
	//Animate the view out
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	[banner setFrame:CGRectMake(0, screen.size.height+banner.frame.size.height, screen.size.width, banner.frame.size.height)];
	[UIView commitAnimations];
}

#pragma mark Memory Management
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return YES;
	else return NO;
	
	return NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
	[songCells removeAllObjects];
	[songCells release];
	
	[statusCell release];
	
	[musicController release]; [scoreController release];
	adBanner.delegate = nil;
	
    [super dealloc];
}


@end

