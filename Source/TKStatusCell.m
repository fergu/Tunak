//
//  TKPadGameStatusView.m
//  Tunak
//
//  Created by Kevin Ferguson on 9/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKStatusCell.h"


@implementation TKStatusCell
@synthesize statusLabel, totalScoreLabel, highScoreLabel, correctGuessesLabel, totalGuessesLabel, averageScoreLabel, accuracyLabel, correctAnswerLabel;

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return YES;
	else return NO;
	
	return NO;
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TK_STATUS_CELL"];
	
    if (cell == nil) {
		UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
		
		if (idiom == UIUserInterfaceIdiomPhone)
			[[NSBundle mainBundle] loadNibNamed:@"TKPhoneStatusCell" owner:self options:nil];
		if (idiom == UIUserInterfaceIdiomPad)
			[[NSBundle mainBundle] loadNibNamed:@"TKPadStatusCell" owner:self options:nil];
		cell = statusCell;
    }
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
	
	if (idiom == UIUserInterfaceIdiomPhone)
		return 115;
	if (idiom == UIUserInterfaceIdiomPad)
		return 350;
	
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	self.statusLabel = nil;
	self.totalScoreLabel = nil;
	self.highScoreLabel = nil;
	self.correctGuessesLabel = nil;
	self.totalGuessesLabel = nil;
	self.averageScoreLabel = nil;
	self.accuracyLabel = nil;
	self.correctAnswerLabel = nil;
	
    [super dealloc];
}


@end

