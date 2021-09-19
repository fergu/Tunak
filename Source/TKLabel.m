//
//  TKLabel.m
//  Tunak
//
//  Created by Kevin Ferguson on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKLabel.h"


@implementation TKLabel

- (void)drawTextInRect:(CGRect)rect {
	
	CGSize shadowOffset = self.shadowOffset;
	UIColor *textColor = self.textColor;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(c, 5);
	
	CGContextSetTextDrawingMode(c, kCGTextStroke);
	self.textColor = [UIColor whiteColor];
	[super drawTextInRect:rect];
	
	CGContextSetTextDrawingMode(c, kCGTextFill);
	self.textColor = textColor;
	self.shadowOffset = CGSizeMake(0, 0);
	[super drawTextInRect:rect];
	
	self.shadowOffset = shadowOffset;
}

@end
