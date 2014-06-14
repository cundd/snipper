//
//  SnipperOSDWindow.m
//  Snipper
//
//  Created by Daniel Corn on 04.02.11.
//  Copyright 2011 cundd. All rights reserved.
//

#import "SnipperOSDWindow.h"


@implementation SnipperOSDWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	if(!self) return nil;
    [self setBackgroundColor: [NSColor clearColor]];
    [self setOpaque:NO];
	
    return self;
}

-(void)makeKeyWindow{
	[super makeKeyWindow];
	[[self animator] setAlphaValue:1.0];
}
-(void)resignKeyWindow{
	[super resignKeyWindow];
	[[self animator] setAlphaValue:0.0];
}
@end
