//
//  SnippetCollectionViewDelegate.m
//  Snipper
//
//  Created by Daniel Corn on 09.12.10.
//  Copyright 2010 cundd. All rights reserved.
//

#import "SnippetCollectionViewDelegate.h"
#import "Snipper_AppDelegate.h"


@implementation SnippetCollectionViewDelegate
+(id)snippetCollectionViewDelegateWithSnippetController:(NSArrayController *)theSnippetController{
	return [[self alloc] initWithSnippetController:theSnippetController];
}
-(id)initWithSnippetController:(NSArrayController *)theSnippetController{
	self = [self init];
	if(self){
		snippetController = theSnippetController;
	}
	return self;
}
-(BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
	Snippet * theSnippet = [(NSArray *)[snippetController arrangedObjects] objectAtIndex:[indexes firstIndex]];
	return [(Snipper_AppDelegate *)[NSApp delegate] addSnippet:theSnippet toPasteboard:pasteboard];
}



-(NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset{
	return [collectionView draggingImageForItemsAtIndexes:indexes withEvent:event offset:dragImageOffset];
}
@end
