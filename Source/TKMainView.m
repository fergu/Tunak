//
//  TunakViewController.m
//  Tunak
//
//  Created by Kevin Ferguson on 8/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Constants.h"
#import "TunakAppDelegate.h"
#import "TKMainView.h"
#import "TKGameView.h"

@implementation TKMainView
@synthesize audioPlayer;

#pragma mark Initialization
-(id)initForDeviceType:(UIDevice *)device
{
	if (self = [super init])
	{
		UIUserInterfaceIdiom idiom = [device userInterfaceIdiom];
		
		if (idiom == UIUserInterfaceIdiomPhone)
			[[NSBundle mainBundle] loadNibNamed:@"TKPhoneMainView" owner:self options:nil];
		
		if (idiom == UIUserInterfaceIdiomPad)
			[[NSBundle mainBundle] loadNibNamed:@"TKPadMainView" owner:self options:nil];
	}
	return self;
}

-(void)initializeController
{
	//Set up the scroller
	[modePickerScroller setContentSize:CGSizeMake(self.view.frame.size.width*3, 0)];
	albumImageArray = [[NSArray alloc] initWithObjects:imageView1, imageView2, imageView3, imageView4, nil];
	[imageView1 release]; [imageView2 release]; [imageView3 release]; [imageView4 release];
	
	//Find and load 4 songs with artwork
	NSArray *_items = [[MPMediaQuery albumsQuery] items];
	
	srand([[NSDate date] timeIntervalSinceReferenceDate]);
	
	for (UIImageView *imageView in albumImageArray)
	{
		int selection = rand() % [_items count];
		
		MPMediaItem *media = [_items objectAtIndex:selection];
		
		if ([media valueForProperty:MPMediaItemPropertyArtwork])
		{
			UIImage *image = [[media valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:imageView.frame.size];
			
			if (image != nil)
				[imageView setImage:image];
		}
	}
	
	running = NO;
}

-(void)viewDidLoad
{
}

#pragma mark View Handling
-(void)viewDidAppear:(BOOL)animated
{
	((TunakAppDelegate *)[[UIApplication sharedApplication] delegate]).gameController = nil;
	[self resume];
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self pause];
	[super viewDidDisappear:animated];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Status Control
-(void)pause
{
	running = NO;
	[audioPlayer pause];
	[imageSwitchTimer invalidate];
	[songSwitchTimer invalidate];
}

-(void)resume
{
	if (![self canRun])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need more songs" message:@"Tunac needs more songs to run properly.\nPlease add more songs to your device and launch Tunac again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	if (!running)
	{
		//Start the album timer
		imageSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(changeArtworkImage) userInfo:nil repeats:YES];
		[imageSwitchTimer fire];
		//Start the music
		songSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:25 target:self selector:@selector(loadSong) userInfo:nil repeats:YES];
		[songSwitchTimer fire];
		
		running = YES;
	}
}

-(BOOL)canRun
{	
	if ([[[MPMediaQuery songsQuery] items] count] < 20)
		return NO;
	
	return YES;
}

#pragma mark Image Switching
-(void)changeArtworkImage
{	
	int item = rand() % [albumImageArray count];
	
	NSArray *_albumArray = [[MPMediaQuery albumsQuery] items];
	
	while (1)
	{
		int media = rand() % [_albumArray count];
		
		MPMediaItem *_mediaItem = [_albumArray objectAtIndex:media];
		
		UIImageView *imageView = [albumImageArray objectAtIndex:item];
		MPMediaItemArtwork *_artwork = [_mediaItem valueForProperty:MPMediaItemPropertyArtwork];
		UIImage *image = [_artwork imageWithSize:imageView.frame.size];
		if (image)
		{
			CATransition *transition = [CATransition animation];
			transition.duration = 1.0f;
			transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			transition.type = kCATransitionFade;
			
			[imageView setImage:[_artwork imageWithSize:imageView.frame.size]];
			
			[imageView.layer addAnimation:transition forKey:nil];
			break;
		}
	}	
}

#pragma mark Song Switching
-(void)loadSong
{	
	NSArray *_musicItems = [[MPMediaQuery artistsQuery] items];
	
	int selection;
	MPMediaItem *_item;
	NSNumber  *_songToPlayLength;
	
	while (1)
	{
		selection = rand() % [_musicItems count];
		_item = [_musicItems objectAtIndex:selection];
		
		_songToPlayLength = [_item valueForProperty:MPMediaItemPropertyPlaybackDuration];
		
		if ([_songToPlayLength intValue] > 45)
			break;
	}
	
	NSInteger playbackTime = (rand() % [_songToPlayLength intValue]) - 30;
	if (playbackTime < 0) playbackTime = 0;
	
	NSURL *_itemLocation = [_item valueForProperty:MPMediaItemPropertyAssetURL];
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_itemLocation options:nil];
	NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
	AVAssetTrack *track = [audioTracks objectAtIndex:0];
	
	float maxVol = [[MPMusicPlayerController applicationMusicPlayer] volume];
	AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
	//Start at 0
	[audioInputParams setVolume:0.0 atTime:kCMTimeZero];
	//Ramp up
	[audioInputParams setVolumeRampFromStartVolume:0.0f toEndVolume:maxVol timeRange:CMTimeRangeMake(CMTimeMake(playbackTime, 1), CMTimeMake(2, 1))];
	//Ramp down
	[audioInputParams setVolumeRampFromStartVolume:maxVol toEndVolume:0 timeRange:CMTimeRangeMake(CMTimeMake(playbackTime+20, 1), CMTimeMake(2, 1))];
	
	[audioInputParams setTrackID:[track trackID]];
	
	AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
	[audioMix setInputParameters:[NSArray arrayWithObject:audioInputParams]];
	
	// Create a player item
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
	[playerItem setAudioMix:audioMix]; // Mute the player item
	
	AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
	[player seekToTime:CMTimeMake(playbackTime, 1)];
	
	// assign player object to an instance variable
	self.audioPlayer = player;
	// play the muted audio
	[audioPlayer play];
}

#pragma mark Game Loading
-(IBAction)beginHighScore
{
	if (![self canRun])
		return;
	
	TKGameView *_controller = [[TKGameView alloc] initForDeviceType:[UIDevice currentDevice]];
	_controller.gameMode = TK_MODE_POINTS;
	
	_controller.modalPresentationStyle = UIModalPresentationFullScreen;
	_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:_controller animated:YES];
	
	((TunakAppDelegate *)[[UIApplication sharedApplication] delegate]).gameController = _controller;
	[_controller release];
}

-(IBAction)beginEndurance
{
	if (![self canRun])
		return;
	
	TKGameView *_controller = [[TKGameView alloc] initForDeviceType:[UIDevice currentDevice]];
	_controller.gameMode = TK_MODE_ENDURANCE;
	
	_controller.modalPresentationStyle = UIModalPresentationFullScreen;
	_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:_controller animated:YES];
	
	((TunakAppDelegate *)[[UIApplication sharedApplication] delegate]).gameController = _controller;
	[_controller release];
}

-(IBAction)beginAccuracy
{
	if (![self canRun])
		return;
	
	TKGameView *_controller = [[TKGameView alloc] initForDeviceType:[UIDevice currentDevice]];
	_controller.gameMode = TK_MODE_ACCURACY;
	
	_controller.modalPresentationStyle = UIModalPresentationFullScreen;
	_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:_controller animated:YES];
	
	((TunakAppDelegate *)[[UIApplication sharedApplication] delegate]).gameController = _controller;
	[_controller release];
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	pageController.currentPage = page;
}

#pragma mark Memory Management
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return YES;
	else return NO;
	
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.audioPlayer = nil;
	
	[albumImageArray release];
    [super dealloc];
}
@end
