//
//  SnipperOSDView.m
//  Snipper
//
//  Created by Daniel Corn on 04.02.11.
//  Copyright 2011 cundd. All rights reserved.
//

#import "SnipperOSDView.h"


@implementation SnipperOSDView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithDeviceWhite:0 alpha:.7] set];
    [[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:10 yRadius:10] fill];
    //Additional drawing
}
- (NSView *)hitTest:(NSPoint)aPoint {
    return nil;
}
- (BOOL)acceptsFirstResponder {
    return NO;
}
- (BOOL)isOpaque {
    return NO;
}
@end
