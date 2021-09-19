//
//  TKSongCell.m
//  Tunak 2
//
//  Created by Kevin Ferguson on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKSongCell.h"

@implementation TKSongCell
@synthesize mediaItem;
#pragma mark Initialization
-(void)initForDeviceType:(UIDevice *)device
{
	if (self = [super init])
	{
		UIUserInterfaceIdiom idiom = [device userInterfaceIdiom];
		
		if (idiom == UIUserInterfaceIdiomPhone)
			[[NSBundle mainBundle] loadNibNamed:@"TKPhoneSongCell" owner:self options:nil];
		
		if (idiom == UIUserInterfaceIdiomPad)
			[[NSBundle mainBundle] loadNibNamed:@"TKPadSongCell" owner:self options:nil];
	}
}

#pragma mark View Configuration
-(void)setIsLoading
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	songAlbumLabel.alpha = 0;
	songTitleLabel.alpha = 0;
	songArtistLabel.alpha = 0;
	songArtworkView.alpha = 0;
	
	[activityIndicator startAnimating];
	activityIndicator.alpha = 1;
	
	[UIView commitAnimations];
}

-(void)setIsDisplaying
{
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	songAlbumLabel.alpha = 1;
	songTitleLabel.alpha = 1;
	songArtistLabel.alpha = 1;
	songArtworkView.alpha = 1;
	
	[activityIndicator stopAnimating];
	activityIndicator.alpha = 0;
	
	[UIView commitAnimations];
}

-(void)configureCell
{	
	songTitleLabel.text = [self.mediaItem valueForProperty:MPMediaItemPropertyTitle];
	songArtistLabel.text = [NSString stringWithFormat:@"By: %@", [self.mediaItem valueForProperty:MPMediaItemPropertyArtist]];
	songAlbumLabel.text = [NSString stringWithFormat:@"Album: %@", [self.mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle]];
	
	MPMediaItemArtwork *_artwork = [self.mediaItem valueForProperty:MPMediaItemPropertyArtwork];
	
	UIImage *_artworkImage = [_artwork imageWithSize:CGSizeMake(280, 280)];
	
	if (!_artworkImage)
		_artworkImage = [UIImage imageNamed:@"NoArtwork.png"];
	
	[songArtworkView setImage:_artworkImage];
	
	[self setIsDisplaying];
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.mediaItem = nil;
    [super dealloc];
}
@end
