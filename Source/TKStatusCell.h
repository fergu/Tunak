//
//  TKStatusCell.h
//  Tunak 2
//
//  Created by Kevin Ferguson on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TKStatusCell : UITableViewController
{
	IBOutlet UITableViewCell *statusCell;
	
	IBOutlet UILabel *statusLabel, *totalScoreLabel, *highScoreLabel, *correctGuessesLabel, *totalGuessesLabel, *averageScoreLabel, *accuracyLabel, *correctAnswerLabel;
}

@property (nonatomic, retain) UILabel *statusLabel, *totalScoreLabel, *highScoreLabel, *correctGuessesLabel, *totalGuessesLabel, *averageScoreLabel, *accuracyLabel, *correctAnswerLabel;
@end
