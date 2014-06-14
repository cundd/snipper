//
//  Snippet.h
//  Snipper
//
//  Created by Daniel Corn on 09.12.10.
//  Copyright (c) 2010 cundd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Snippet : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * password;
@property (nonatomic, strong) NSNumber * sortOrder;
@property (nonatomic, strong) NSDate * modificationDate;
@property (nonatomic, strong) NSDate * creationDate;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * snippet;
@property (nonatomic, strong) NSNumber * uid;
@property (readonly) NSString * sortOrderUTF8;


-(void)connectedButtonWasPressed:(id)sender;

@end
