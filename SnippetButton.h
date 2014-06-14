//
//  BackgroundButton.h
//  Snipper
//
//  Created by Daniel Corn on 08.12.10.
//  Copyright 2010 cundd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/NSDragging.h>
#import "Snippet.h"


@interface SnippetButton : NSButton{
	Snippet * __strong snippet;
}
@property (strong,nonatomic) Snippet * snippet;
@end
