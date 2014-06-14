//
//  SnippetCollectionView.m
//  Snipper
//
//  Created by Daniel Corn on 09.12.10.
//  Copyright 2010 cundd. All rights reserved.
//

#import "SnippetCollectionView.h"


@implementation SnippetCollectionView
-(void)awakeFromNib{
	[self setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

-(void)mouseDown:(NSEvent *)theEvent{
	NSLog(@"mouseDown delegate:%@",[self delegate]);
	[super mouseDown:theEvent];
}
-(void)mouseDragged:(NSEvent *)theEvent{
	NSLog(@"selected %@",theEvent);
//	[super mouseDragged:theEvent];
	
}
///*
//-(void)startDragWithEvent:(NSEvent *)theEvent{
//	if([self.delegate respondsToSelector:@selector(collectionView:canDragItemsAtIndexes:withEvent:)]){
//		[self.delegate collectionView:self canDragItemsAtIndexes:indexSet withEvent:theEvent];
//	}
//	if([self.delegate respondsToSelector:@selector(collectionView:draggingImageForItemsAtIndexes:withEvent:offset:)]){
//		[self.delegate collectionView:self draggingImageForItemsAtIndexes:indexSet withEvent:theEvent offset:offset]
//	}
//	if([self.delegate respondsToSelector:@selector(collectionView:writeItemsAtIndexes:toPasteboard:)]){
//		[self.delegate collectionView:self writeItemsAtIndexes:indexSet toPasteboard:<#(NSPasteboard *)#>]
//	}
//}
///* */snippet6
@end
