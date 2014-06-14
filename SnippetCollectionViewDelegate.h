//
//  SnippetCollectionViewDelegate.h
//  Snipper
//
//  Created by Daniel Corn on 09.12.10.
//  Copyright 2010 cundd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSCollectionView.h>
#import "Snippet.h"


@interface SnippetCollectionViewDelegate : NSObject <NSCollectionViewDelegate> {
	NSArrayController * snippetController;
@private
    
}
+(id)snippetCollectionViewDelegateWithSnippetController:(NSArrayController *)theSnippetController;
-(id)initWithSnippetController:(NSArrayController *)theSnippetController;
@end
