//
//  Snipper_AppDelegate.h
//  Snipper
//
//  Created by Daniel Corn on 08.12.10.
//  Copyright cundd 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "Snippet.h"
#import "SnippetButton.h"
#import "SnippetPanel.h"
#import "SnippetCollectionViewDelegate.h"
#import "SnipperOSDView.h"
#import "SnipperOSDWindow.h"

typedef enum{
	SnipperPasteModePasteTitleCopySnippet		= 0,
	SnipperPasteModePasteAndCopySnippet			= 1,
	SnipperPasteModePasteSnippetCopyTitle		= 2,
	SnipperPasteModePasteTitleCopyPasteboard	= 3,
	SnipperPasteModePasteSnippetCopyPasteboard	= 4
} SnipperPasteMode;

@interface Snipper_AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    NSWindow *window;
	NSWindow * __strong preferencePanel;
    SnippetPanel * __strong snippetPanel;
	NSCollectionView * __strong collectionView;
	NSSegmentedControl * __strong modifierKeysControl;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
	SnippetCollectionViewDelegate * __strong collectionViewDelegate;
    Snippet * __strong selectedSnippet;
	Snippet * scheduledSnippet;
	NSArrayController * __strong snippetController;
	SnipperPasteMode pasteMode;
	int modifierKeys;
	
	NSMutableArray * hotKeyRefs;
	EventHotKeyRef hotSwapHotKeysCopyRef;
	EventHotKeyRef hotSwapHotKeysPasteRef;
	BOOL hotSwapHotKeysRefAreRegistered;
	
	NSArray * sortDescriptors;
	
	BOOL pasteScheduled;
	NSArray * pasteboardData;
}

@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (readonly) int modifierKeys;
@property  NSArray * sortDescriptors;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) Snippet * selectedSnippet;
@property (strong,nonatomic) SnippetCollectionViewDelegate * collectionViewDelegate;

@property (strong,nonatomic) IBOutlet SnippetPanel * snippetPanel;
@property (strong,nonatomic) IBOutlet NSCollectionView * collectionView;
@property (strong,nonatomic) IBOutlet NSArrayController * snippetController;
@property (strong,nonatomic) IBOutlet NSWindow * preferencePanel;
@property (strong,nonatomic) IBOutlet NSSegmentedControl * modifierKeysControl;

@property (readonly) NSArray * pasteboardData;

@property (assign) BOOL pasteScheduled;

- (IBAction)saveAction:(id)sender;
- (IBAction)closeWindow:(id)sender;

/*!
    @method     
    @abstract   Saves the current state of the content.
    @discussion Saves the current state of the content.
*/
-(void)save;

/*!
    @method     
    @abstract   Creates a set of empty snippets.
    @discussion Creates a set of empty snippets.
*/
-(void)initEmptySnippets;

/*!
    @method     
    @abstract   Opens the panel for snippet configuration.
    @discussion Opens the panel for snippet configuration.
*/
-(void) openSnippetPanelForSnippet:(Snippet *)theSnippet;

/*!
 @method     
 @abstract   Opens the OSD like window for the snippets.
 @discussion Opens the OSD like window for the snippets.
 */
-(void) openSnippetOSD;

/*!
    @method     
    @abstract   Opens the panel for snippet configuration.
    @discussion Opens the panel for snippet configuration.
*/
-(IBAction)openSnippetPanel:(id)sender;
-(IBAction)openPreferencePanel:(id)sender;
-(IBAction)modifierKeysControlClicked:(id)sender;

-(BOOL)addSnippet:(Snippet *)theSnippet toPasteboard:(NSPasteboard *)thePasteboard;
-(BOOL)addString:(NSString *)theString toPasteboard:(NSPasteboard *)thePasteboard;
-(void)registerHotkeys;
-(void)updateHotSwapHotKeys;

-(OSStatus)pasteObjectForIndex:(int)index forKeyPress:(BOOL)keyPressed;

//-(OSStatus)pasteScheduledObject;
//-(OSStatus)copyScheduledObjectToPasteboard;
//
//-(OSStatus)schedulePasteObjectForIndex:(int)index;

-(void)sendPaste;

-(OSStatus)copyHotSwap;
-(OSStatus)pasteHotSwap;

-(void)cachePasteboardData;
-(BOOL)resetPasteboardData;


@end
