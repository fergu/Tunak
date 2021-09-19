//
//  TKSongCell.h
//  Tunak 2
//
//  Created by Kevin Ferguson on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TKSongCell : UITableViewCell
{
	MPMediaItem *mediaItem;
	
	//IBOutlets
	IBOutlet UILabel *songTitleLabel, *songAlbumLabel, *songArtistLabel;
	IBOutlet UIImageView *songArtworkView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

-(void)setIsLoading;
-(void)setIsDisplaying;
-(void)configureCell;

@property (nonatomic, retain) MPMediaItem *mediaItem;
@end
