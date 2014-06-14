//
//  Snippet.m
//  Snipper
//
//  Created by Daniel Corn on 09.12.10.
//  Copyright (c) 2010 cundd. All rights reserved.
//

#import "Snippet.h"
#import "Snipper_AppDelegate.h"


@implementation Snippet
@dynamic password;
@dynamic sortOrder;
@dynamic modificationDate;
@dynamic creationDate;
@dynamic title;
@dynamic snippet;
@dynamic uid;

-(void)connectedButtonWasPressed:(id)sender{
    [(Snipper_AppDelegate *)[NSApp delegate] openSnippetPanel:self];
}

-(void)didChangeValueForKey:(NSString *)key{
	if(![key isEqualToString:@"modificationDate"]){
		self.modificationDate = [NSDate date];
	}
	[super didChangeValueForKey:key];
}
-(NSString *)description{
	return [NSString stringWithFormat:@"<Snippet: #%@>%@ - %@ sortOrder=%@",self.uid, self.title, self.snippet,self.sortOrder];
}

-(NSString *)sortOrderUTF8{
	NSInteger sortOrderInt = [[self sortOrder] intValue];
	NSString * utf8string;
	
	switch(sortOrderInt){
		case 1:
			utf8string = @"➊";
			break;
			
		case 2:
			utf8string = @"➋";
			break;
			
		case 3:
			utf8string = @"➌";
			break;
			
		case 4:
			utf8string = @"➍";
			break;
			
		case 5:
			utf8string = @"➎";
			break;
			
		case 6:
			utf8string = @"➏";
			break;
			
		case 7:
			utf8string = @"➐";
			break;
			
		case 8:
			utf8string = @"➑";
			break;
			
		case 9:
			utf8string = @"➒";
			break;
			
		case 10:
			utf8string = @"➓";
			break;
			
		default:
			utf8string = @"➓";
			break;
			
	}
	return utf8string;
}


#if 0

- (NSNumber *)sortOrder {
	NSNumber * tmpValue;
	
	[self willAccessValueForKey:@"sortOrder"];
	tmpValue = [self primitiveSortOrder];
	
	[self didAccessValueForKey:@"sortOrder"];
	
	//	tmpValue = [NSNumber numberWithFloat:[tmpValue floatValue] + 1.0];
	
	return tmpValue;
}



/*
 *
 * Property methods not providing customized implementations should be removed.
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
 */
- (void)setSnippet:(NSString *)value {
	NSLog(@"New snippet %@ uid=%@",value,self.uid);
    [self willChangeValueForKey:@"snippet"];
    [self setPrimitiveSnippet:value];
    [self didChangeValueForKey:@"snippet"];
	NSLog(@"Saved snippet %@ uid=%@",self.snippet,self.uid);
}

- (NSString *)snippet {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"snippet"];
    tmpValue = [self primitiveSnippet];
    [self didAccessValueForKey:@"snippet"];
    
	NSLog(@"accessed snippet value %@ uid=%@",tmpValue,self.uid);
    return tmpValue;
}

- (NSNumber *)password {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"password"];
    tmpValue = [self primitivePassword];
    [self didAccessValueForKey:@"password"];
    
    return tmpValue;
}

- (void)setPassword:(NSNumber *)value {
    [self willChangeValueForKey:@"password"];
    [self setPrimitivePassword:value];
    [self didChangeValueForKey:@"password"];
}

- (BOOL)validatePassword:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (void)setSortOrder:(NSNumber *)value {
    [self willChangeValueForKey:@"sortOrder"];
    [self setPrimitiveSortOrder:value];
    [self didChangeValueForKey:@"sortOrder"];
}

- (BOOL)validateSortOrder:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSDate *)modificationDate {
    NSDate * tmpValue;
    
    [self willAccessValueForKey:@"modificationDate"];
    tmpValue = [self primitiveModificationDate];
    [self didAccessValueForKey:@"modificationDate"];
    
    return tmpValue;
}

- (void)setModificationDate:(NSDate *)value {
    [self willChangeValueForKey:@"modificationDate"];
    [self setPrimitiveModificationDate:value];
    [self didChangeValueForKey:@"modificationDate"];
}

- (BOOL)validateModificationDate:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSDate *)creationDate {
    NSDate * tmpValue;
    
    [self willAccessValueForKey:@"creationDate"];
    tmpValue = [self primitiveCreationDate];
    [self didAccessValueForKey:@"creationDate"];
    
    return tmpValue;
}

- (void)setCreationDate:(NSDate *)value {
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveCreationDate:value];
    [self didChangeValueForKey:@"creationDate"];
}

- (BOOL)validateCreationDate:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)title {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"title"];
    tmpValue = [self primitiveTitle];
    [self didAccessValueForKey:@"title"];
    
    return tmpValue;
}

- (void)setTitle:(NSString *)value {
    [self willChangeValueForKey:@"title"];
    [self setPrimitiveTitle:value];
    [self didChangeValueForKey:@"title"];
}

- (BOOL)validateTitle:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (void)setSnippet:(NSString *)value {
    [self willChangeValueForKey:@"snippet"];
    [self setPrimitiveSnippet:value];
    [self didChangeValueForKey:@"snippet"];
}

- (BOOL)validateSnippet:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)uid {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"uid"];
    tmpValue = [self primitiveUid];
    [self didAccessValueForKey:@"uid"];
    
    return tmpValue;
}

- (void)setUid:(NSNumber *)value {
    [self willChangeValueForKey:@"uid"];
    [self setPrimitiveUid:value];
    [self didChangeValueForKey:@"uid"];
}

- (BOOL)validateUid:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}
#endif

@end
