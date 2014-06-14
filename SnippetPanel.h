//
//  SnippetPanel.h
//  Snipper
//
//  Created by Daniel Corn on 20.12.10.
//  Copyright 2010 cundd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SnippetPanel : NSPanel {
	IBOutlet NSTextField *snippetTitle;
	IBOutlet NSTextView *snippet;
}

@property (strong) NSTextField * snippetTitle;
@property (strong) NSTextView * snippet;

@end
