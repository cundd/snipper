//
//  Snipper_AppDelegate.m
//  Snipper
//
//  Created by Daniel Corn on 08.12.10.
//  Copyright cundd 2010 . All rights reserved.
//

#define kPasteHotKeyId 100
#define kSnipperHotSwapHotKeyCopyId 200
#define kSnipperHotSwapHotKeyPasteId 202
#define kSnipperHotSwapEnabled NO
// kCGHIDEventTap, kCGAnnotatedSessionEventTap, kCGSessionEventTap
#define kSnipperEventTap kCGAnnotatedSessionEventTap

#import "Snipper_AppDelegate.h"


@interface Snipper_AppDelegate(private)
-(void)_updatePasteMode;
-(void)_updateModifierKeys;
-(void)_alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation Snipper_AppDelegate

#pragma mark Hot key handler callback
OSStatus hotKeyPressHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void * userData){
	OSStatus error = noErr;
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	int ID = hotKeyID.id;
	
	if(ID != kSnipperHotSwapHotKeyCopyId && ID != kSnipperHotSwapHotKeyPasteId){
		[(__bridge Snipper_AppDelegate *)userData openSnippetOSD];
		error = [(__bridge Snipper_AppDelegate *)userData pasteObjectForIndex:ID forKeyPress:YES];
	}
	
//	if([(Snipper_AppDelegate *)userData pasteScheduled]){
//		error = [(Snipper_AppDelegate *)userData pasteScheduledObject];
//	} else if(ID != kPasteHotKeyId){
//		error = [(Snipper_AppDelegate *)userData schedulePasteObjectForIndex:ID];
//	} else {
//		// Do nothing
//	}
//	
//	NSLog(@"pressed %i scheduled=%i",ID,[(Snipper_AppDelegate *)userData pasteScheduled]);
	return error;
}
OSStatus hotKeyReleaseHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void * userData){
	OSStatus error = noErr;
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	int ID = hotKeyID.id;
	
	if(ID == kSnipperHotSwapHotKeyCopyId){
		error = [(__bridge Snipper_AppDelegate *)userData copyHotSwap];
	} else if(ID == kSnipperHotSwapHotKeyPasteId){
		error = [(__bridge Snipper_AppDelegate *)userData pasteHotSwap];
	} else {
		error = [(__bridge Snipper_AppDelegate *)userData pasteObjectForIndex:ID forKeyPress:NO];
	}
	
//	if([(Snipper_AppDelegate *)userData pasteScheduled]){
//		error = [(Snipper_AppDelegate *)userData copyScheduledObjectToPasteboard];
//	}
//	
//	NSLog(@"released %i scheduled=%i",ID,[(Snipper_AppDelegate *)userData pasteScheduled]);
	return error;
}

#pragma mark Syntesized accessors
@synthesize window,selectedSnippet,snippetPanel,collectionView,collectionViewDelegate,snippetController,preferencePanel,modifierKeysControl,sortDescriptors,pasteScheduled;

#pragma mark Application initialization
-(void) applicationDidFinishLaunching:(NSNotification *)notification{
	// Init
	hotKeyRefs = [NSMutableArray array];
	
	// Init Core Data
	NSManagedObjectContext * moc = [self managedObjectContext];
	NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"Snippet" 
														  inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"snippet != \"\""];
	[request setPredicate:predicate];
	
	
	[request setSortDescriptors:self.sortDescriptors];
	
	
	// Fetch the entries
	NSError *error = nil;
	NSArray *result = [moc executeFetchRequest:request error:&error];
	if (![result count]){
		[self initEmptySnippets];
	}
	
	// Create the collection view delegate
	collectionViewDelegate = [SnippetCollectionViewDelegate snippetCollectionViewDelegateWithSnippetController:snippetController];
	
	if(!collectionView) [NSApp terminate:@"No collection view"];
	[collectionView setDelegate:collectionViewDelegate];
	
	// Register the default values for the user defaults
	NSDictionary * defaultValuesDict = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES],@"modifierKey0",
										[NSNumber numberWithBool:YES],@"modifierKey1",
										[NSNumber numberWithBool:NO],@"modifierKey2",
										nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValuesDict];
	
	// Register the hotkeys
	[self registerHotkeys];
	[self _updatePasteMode];
	
	// Initialize the modifier keys
	[self _updateModifierKeys];
	
	// Init the hot swap
	[self updateHotSwapHotKeys];
	
	// Register the observer for changes in the preferences
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"pasteMode" options:NSKeyValueObservingOptionNew context:nil];
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"hotSwapHotKeys" options:NSKeyValueObservingOptionNew context:nil];
	
	
	// Install event handler
	EventTypeSpec eventTypePress,eventTypeRelease;
	
	eventTypeRelease.eventClass = kEventClassKeyboard;
	eventTypeRelease.eventKind = kEventHotKeyReleased;
	
	eventTypePress.eventClass = kEventClassKeyboard;
	eventTypePress.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&hotKeyPressHandler,1,&eventTypePress,(__bridge void *)self,NULL);
	InstallApplicationEventHandler(&hotKeyReleaseHandler,1,&eventTypeRelease,(__bridge void *)self,NULL);
	
	
	
//	hotKeyID.signature = 'hkep';
//	hotKeyID.id = kPasteHotKeyId;
//	RegisterEventHotKey(9, cmdKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
	
	// Set the font of the snippet input
	NSFont * snippetFont = [NSFont fontWithName:@"Lucida Grande" size:13.0];
	[snippetPanel.snippet setFont:snippetFont];
	
//	CGEventRef unCommand = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)50,	false);
//	CGEventPost(kCGSessionEventTap, unCommand);
//	CFRelease(unCommand);
}

-(NSArray *)sortDescriptors{
	if(!sortDescriptors){
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
											initWithKey:@"sortOrder" ascending:YES];
		sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	}
	return sortDescriptors;
}

-(void) initEmptySnippets{
	NSManagedObjectContext * moc = [self managedObjectContext];
	
	Snippet * aSnippet;
	for(int i = 1;i <= 9;i++){
		NSNumber * iNumber = [NSNumber numberWithInt:i];
		aSnippet = [NSEntityDescription insertNewObjectForEntityForName:@"Snippet" inManagedObjectContext:moc];
		
		aSnippet.title = [NSString stringWithFormat:@"Title %i",i];
		aSnippet.snippet = [NSString stringWithFormat:@"Snippet %i",i];
		aSnippet.sortOrder = iNumber;
		aSnippet.uid = iNumber;
		aSnippet.creationDate = [NSDate date];
		aSnippet.modificationDate = [NSDate date];
	}	
}

#pragma mark Snippet configuration panel
-(void) openSnippetPanelForSnippet:(Snippet *)theSnippet{
	
	if(![self.snippetPanel isVisible]){
		[self.snippetPanel makeKeyAndOrderFront:nil];
	}
    self.selectedSnippet = theSnippet;
}
-(void) openSnippetPanel:(id)sender{
	[self openSnippetPanelForSnippet:sender];
}

-(void) windowDidResignKey:(NSNotification *)notification{
	if([notification object] == snippetPanel){
		// Update the Core Data context
		self.selectedSnippet.title = snippetPanel.snippetTitle.stringValue;
		
		NSString * snippetText = [NSString stringWithFormat:@"%@",snippetPanel.snippet.textStorage.string];
		self.selectedSnippet.snippet = snippetText;
	}
}
-(void) openSnippetOSD{
	return;
	
	//Create and display window
	SnipperOSDWindow *panel;
	// panel = [[NSPanel alloc] initWithFrame:NSMakeRect(0,0,300,200) styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:YES];
	panel = [[SnipperOSDWindow alloc] initWithContentRect:NSMakeRect(100,100,300,200) styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:YES];
	[panel setOpaque:NO];
	SnipperOSDView *view = [SnipperOSDView new];
	[panel setContentView:view];
	[panel setLevel:NSScreenSaverWindowLevel];
	[panel orderFront:nil];
	
	//Add these two lines to the beginning of the drawRect: method
//	[[NSColor clearColor] set];
//	NSRectFill(self.bounds);
}

#pragma mark Preference panel
-(void)openPreferencePanel:(id)sender{
	[NSBundle loadNibNamed:@"Preferences" owner:self];
	[self.preferencePanel makeKeyWindow];
	
	// Init the key modifier control
    [[self.modifierKeysControl cell] setTag:0 forSegment:0];
	[[self.modifierKeysControl cell] setTag:1 forSegment:1];
    [[self.modifierKeysControl cell] setTag:2 forSegment:2];
    [self.modifierKeysControl setTarget:self];
    [self.modifierKeysControl setAction:@selector(modifierKeysControlClicked:)];
	
	// Init the current state of selection
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	for(NSUInteger i = 0;i < 3;i++){
		NSString * defaultKey = [NSString stringWithFormat:@"modifierKey%lu",(unsigned long)i];
		BOOL isSelected = [[defaults objectForKey:defaultKey] boolValue];
		[self.modifierKeysControl setSelected:isSelected forSegment:i];
	}
}

#pragma mark Pasteboard
-(BOOL)addSnippet:(Snippet *)theSnippet toPasteboard:(NSPasteboard *)thePasteboard{
	NSArray * objectsToWriteToPasteBoard;
	
	NSString * pItem = theSnippet.snippet;
	if(!pItem) pItem = theSnippet.title;
	if(!pItem) pItem = @"";
	objectsToWriteToPasteBoard = [NSArray arrayWithObject:pItem];
	
	[thePasteboard clearContents];
	return [thePasteboard writeObjects:objectsToWriteToPasteBoard];
}
-(BOOL)addString:(NSString *)theString toPasteboard:(NSPasteboard *)thePasteboard{
	NSArray * objectsToWriteToPasteBoard = [NSArray arrayWithObject:theString];
	
	[thePasteboard clearContents];
	return [thePasteboard writeObjects:objectsToWriteToPasteBoard];
}

//-(OSStatus) schedulePasteObjectForIndex:(int)index{
//	scheduledSnippet = [[snippetController arrangedObjects] objectAtIndex:index-1];
//	pasteScheduled = YES;
//	
//	return noErr;
//}
//
//-(OSStatus) pasteScheduledObject{
//	if(!scheduledSnippet){
//		NSLog(@"Error: No snippet to paste scheduled.");
//		return errUnknownElement;
//	}
//	NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSGeneralPboard];
//	OSStatus error = noErr;
//	NSString * pasteObject1;
//	NSString * pasteObject2;
//	
//	switch(pasteMode){
//		case SnipperPasteModePasteTitleCopySnippet:
//			pasteObject1 = scheduledSnippet.title;
//			pasteObject2 = scheduledSnippet.snippet;
//			break;
//			
//		case SnipperPasteModePasteAndCopySnippet:
//			pasteObject1 = scheduledSnippet.snippet;
//			pasteObject2 = scheduledSnippet.snippet;
//			break;
//			
//		case SnipperPasteModePasteSnippetCopyTitle:
//			pasteObject1 = scheduledSnippet.snippet;
//			pasteObject2 = scheduledSnippet.title;
//			break;
//			
//		default:
//			NSLog(@"Error: pasteMode = %i",pasteMode);
//			return errUnknownElement;
//	}
//	
//	if(!pasteObject1) pasteObject1 = @"";
//	
//	// Copy it to the pasteboard
//	error = [self addString:pasteObject1 toPasteboard:pboard];
//	
//	
//	// Send the key events to paste
//	[self sendPaste];
//	
//	return error;
//}
//
//-(OSStatus)copyScheduledObjectToPasteboard{
//	if(!scheduledSnippet){
//		NSLog(@"Error: No snippet to paste scheduled.");
//		return errUnknownElement;
//	}
//	NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSGeneralPboard];
//	OSStatus error = noErr;
//	NSString * pasteObject1;
//	NSString * pasteObject2;
//	
//	switch(pasteMode){
//		case SnipperPasteModePasteTitleCopySnippet:
//			pasteObject1 = scheduledSnippet.title;
//			pasteObject2 = scheduledSnippet.snippet;
//			break;
//			
//		case SnipperPasteModePasteAndCopySnippet:
//			pasteObject1 = scheduledSnippet.snippet;
//			pasteObject2 = scheduledSnippet.snippet;
//			break;
//			
//		case SnipperPasteModePasteSnippetCopyTitle:
//			pasteObject1 = scheduledSnippet.snippet;
//			pasteObject2 = scheduledSnippet.title;
//			break;
//			
//		default:
//			NSLog(@"Error: pasteMode = %i",pasteMode);
//			return errUnknownElement;
//	}
//	
//	if(!pasteObject2) pasteObject2 = @"";
//	
//	// Copy it to the pasteboard
//	error = [self addString:pasteObject2 toPasteboard:pboard];
//	
//	if(error == noErr){
//		pasteScheduled = NO;
//	} else {
//		NSLog(@"error while pasting object 2");
//	}
//	return error;
//}

-(OSStatus)pasteObjectForIndex:(int)index forKeyPress:(BOOL)keyPressed{
	Snippet * theSnippet = [[snippetController arrangedObjects] objectAtIndex:index-1];
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSGeneralPboard];
	OSStatus error = noErr;
	NSString * pasteObject1;
	NSString * pasteObject2;
	BOOL force = false;
	BOOL resetPasteboard = false;
	
	switch(pasteMode){
		case SnipperPasteModePasteTitleCopySnippet:
			pasteObject1 = theSnippet.title;
			pasteObject2 = theSnippet.snippet;
			break;
			
		case SnipperPasteModePasteAndCopySnippet:
			pasteObject1 = theSnippet.snippet;
			pasteObject2 = theSnippet.snippet;
			break;
			
		case SnipperPasteModePasteSnippetCopyTitle:
			pasteObject1 = theSnippet.snippet;
			pasteObject2 = theSnippet.title;
			break;
			
		case SnipperPasteModePasteTitleCopyPasteboard:
			pasteObject1 = theSnippet.title;
			break;
			
		case SnipperPasteModePasteSnippetCopyPasteboard:
			pasteObject1 = theSnippet.snippet;
			break;
			
		default:
			NSLog(@"Error: pasteMode = %i",pasteMode);
			return errUnknownElement;
	}
    
    NSLog(@"Pasting the object for index %i in pastemode %i (keyPressed: %i)", index, pasteMode, keyPressed);
	
	// Check if the snippet is empty -> only insert the title
	if(!theSnippet.snippet || [theSnippet.snippet isEqualToString:@""]){
		pasteObject1 = theSnippet.title;
		resetPasteboard = true;
	}
	
	// Check if the hot keys are pressed or released
	if(keyPressed || force){ // Handle the first paste object
		// Copy it to the pasteboard
		if(!pasteObject1) pasteObject1 = @"";
		if(resetPasteboard){
			[self cachePasteboardData];
		}
		error = [self addString:pasteObject1 toPasteboard:pboard];
		[self sendPaste];
	}
	if(!keyPressed || force){ // Handle the second paste object
		if(pasteMode == SnipperPasteModePasteTitleCopyPasteboard || pasteMode == SnipperPasteModePasteSnippetCopyPasteboard || resetPasteboard){
			[self resetPasteboardData];
		} else {
			// Copy it to the pasteboard
			if(!pasteObject2) pasteObject2 = @"";
			error = [self addString:pasteObject2 toPasteboard:pboard];
		}
	}
	return error;
}
-(id)pasteboardData{
	return pasteboardData;
}
-(void)cachePasteboardData{
//	NSLog(@"Before cache pasteboard data");
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName: NSGeneralPboard];
	
	// Release old cache data
	for (__strong NSObject * data in pasteboardData) {
		data = nil;
	}
	pasteboardData = nil;
	
	// Currently only fetch NSString data
	//	NSArray *classes = [[NSArray alloc] initWithObjects:[NSAttributedString class], [NSString class], nil];
	NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], [NSAttributedString class], [NSString class], [NSPasteboardItem class], nil];
//	NSArray *classes = [[NSArray alloc] initWithObjects: [NSAttributedString class], [NSString class], nil];
	
	NSDictionary *options = [NSDictionary dictionary];
	pasteboardData = [pasteboard readObjectsForClasses:classes options:options];
	
	// Clear the pasteboard
	[pasteboard clearContents];
	
//	NSLog(@"pb data=%lu",[pasteboardData count]);
//	NSLog(@"After cache pasteboard data");
}
-(BOOL)resetPasteboardData{
	BOOL success = true;
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName: NSGeneralPboard];
	if(pasteboardData){
		success *= [pasteboard clearContents];
		success *= [pasteboard writeObjects:pasteboardData];
	} else {
		success = false;
	}
	if(!success) NSLog(@"Couldn't reset the pasteboard data.");
	return success;
}

-(void)_updatePasteMode{
	int userDefaultsPasteMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pasteMode"] intValue];
	if(!userDefaultsPasteMode) userDefaultsPasteMode = 0;
	pasteMode = userDefaultsPasteMode;
}

#pragma mark Setup
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	return YES;
}

#pragma mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"pasteMode"]){
		[self _updatePasteMode];
	} else if([keyPath isEqualToString:@"hotSwapHotKeys"]){
		[self updateHotSwapHotKeys];
	}
}

#pragma mark Send key events
-(void)sendPaste{
	// Send the key events to paste
	CGEventSourceRef source = NULL;
//	source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
	
	CGEventRef vDown, vUp;
	vDown	= CGEventCreateKeyboardEvent (source, (CGKeyCode)9,	true);
	CGEventSetFlags(vDown, kCGEventFlagMaskCommand);
	
	vUp		= CGEventCreateKeyboardEvent (source, (CGKeyCode)9,	false);
	CGEventSetFlags(vUp, kCGEventFlagMaskCommand);
	
	CGEventPost(kSnipperEventTap, vDown);
	CGEventPost(kSnipperEventTap, vUp);
	
	CFRelease(vDown);
	CFRelease(vUp);
}

#pragma mark Hotkeys
-(void) registerHotkeys{
	EventHotKeyRef hotKeyRef1, hotKeyRef2, hotKeyRef3, hotKeyRef4, hotKeyRef5, hotKeyRef6, hotKeyRef7, hotKeyRef8, hotKeyRef9;
	EventHotKeyID hotKeyID;
	int modifier = [self modifierKeys];
	
	// Remove the old hot keys
	NSArray * hotKeyRefsCopy = [NSArray arrayWithArray:hotKeyRefs];
	for(NSValue * hotKeyValue in hotKeyRefsCopy){
		EventHotKeyRef hotKeyRef = [hotKeyValue pointerValue];
		UnregisterEventHotKey(hotKeyRef);
		[hotKeyRefs removeObject:hotKeyValue];
	}
	
	
	
	hotKeyID.signature = 'hke1';
	hotKeyID.id = 1;
	RegisterEventHotKey(18, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef1);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef1]];
	
	hotKeyID.signature = 'hke2';
	hotKeyID.id = 2;
	RegisterEventHotKey(19, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef2);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef2]];
	
	hotKeyID.signature = 'hke3';
	hotKeyID.id = 3;
	RegisterEventHotKey(20, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef3);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef3]];
	
	hotKeyID.signature = 'hke4';
	hotKeyID.id = 4;
	RegisterEventHotKey(21, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef4);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef4]];
	
	hotKeyID.signature = 'hke5';
	hotKeyID.id = 5;
	RegisterEventHotKey(23, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef5);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef5]];

	hotKeyID.signature = 'hke6';
	hotKeyID.id = 6;
	RegisterEventHotKey(22, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef6);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef6]];
	
	hotKeyID.signature = 'hke7';
	hotKeyID.id = 7;
	RegisterEventHotKey(26, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef7);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef7]];
	
	hotKeyID.signature = 'hke8';
	hotKeyID.id = 8;
	RegisterEventHotKey(28, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef8);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef8]];
	
	hotKeyID.signature = 'hke9';
	hotKeyID.id = 9;
	RegisterEventHotKey(25, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef9);
	[hotKeyRefs addObject:[NSValue valueWithPointer:hotKeyRef9]];
	
}

-(int)modifierKeys{
	return modifierKeys;
}

-(void)modifierKeysControlClicked:(id)sender{
	// Get the selected segment and update the corresponding user defaults
	int clickedSegment = [sender selectedSegment];
	BOOL isOn = [sender isSelectedForSegment:clickedSegment];
	NSString * segmentUserDefaultKey = [NSString stringWithFormat:@"modifierKey%i",clickedSegment];
	
	// NSLog(@"is segment %i selected? %i  defaults key=%@",clickedSegment,isOn,segmentUserDefaultKey);
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOn] forKey:segmentUserDefaultKey];
	
	[self _updateModifierKeys];
	[self updateHotSwapHotKeys];
}

-(void)_updateModifierKeys{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	modifierKeys = 0;
	
	if([[defaults objectForKey:@"modifierKey0"] boolValue]){ // Command key
		modifierKeys += cmdKey;
	}
	if([[defaults objectForKey:@"modifierKey1"] boolValue]){ // Option key
		modifierKeys += optionKey;
	}
	if([[defaults objectForKey:@"modifierKey2"] boolValue]){ // Shift key
		modifierKeys += shiftKey;
	}
	
	if(!modifierKeys){ // No modifiers is not allowed
		// Select the last clicked segment
		NSInteger indexOfSelected = [self.modifierKeysControl selectedSegment];
		[self.modifierKeysControl setSelectedSegment:indexOfSelected];
		NSString * segmentUserDefaultKey = [NSString stringWithFormat:@"modifierKey%li",(long)indexOfSelected];
		[defaults setObject:[NSNumber numberWithBool:YES] forKey:segmentUserDefaultKey];
		
		// Display an alert
		NSAlert * alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Ok"];
		[alert setMessageText:@"A modifier key must be specified"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:self.preferencePanel modalDelegate:self didEndSelector:@selector(_alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
	
	[self registerHotkeys];
}

-(void)_alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
	
}

#pragma mark Hot Swap
-(void)createHotSwapSnippet{
	NSManagedObjectContext * moc = [self managedObjectContext];
	
	Snippet * aSnippet;
	NSNumber * iNumber = [NSNumber numberWithInt:1000];
	aSnippet = [NSEntityDescription insertNewObjectForEntityForName:@"Snippet" inManagedObjectContext:moc];
	
	aSnippet.title = [NSString stringWithFormat:@"hotswapTitle"];
	aSnippet.snippet = [NSString stringWithFormat:@"hotswapSnippet"];
	aSnippet.sortOrder = iNumber;
	aSnippet.uid = iNumber;
	aSnippet.creationDate = [NSDate date];
	aSnippet.modificationDate = [NSDate date];
	
}
-(void)updateHotSwapHotKeys{
	// Check if Hot Swap is enabled
	if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"hotSwapHotKeys"] boolValue] && kSnipperHotSwapEnabled){
		hotSwapHotKeysRefAreRegistered = YES;
		return;
	}
	
	// Unregister if registered
	if(hotSwapHotKeysRefAreRegistered){
		UnregisterEventHotKey(hotSwapHotKeysCopyRef);
		UnregisterEventHotKey(hotSwapHotKeysPasteRef);
		hotSwapHotKeysRefAreRegistered = NO;
	}
	EventHotKeyID hotKeyID;
	int modifier = [self modifierKeys];
	
	// Register Copy
	hotKeyID.signature = 'hksc';
	hotKeyID.id = kSnipperHotSwapHotKeyCopyId;
	RegisterEventHotKey(8, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotSwapHotKeysCopyRef);
	
	// Register Paste
	hotKeyID.signature = 'hksp';
	hotKeyID.id = kSnipperHotSwapHotKeyPasteId;
	RegisterEventHotKey(8, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotSwapHotKeysPasteRef);
	
	hotSwapHotKeysRefAreRegistered = YES;
}

-(OSStatus)copyHotSwap{
	return noErr;
}

-(OSStatus)pasteHotSwap{
	return noErr;
}

#pragma mark Core Data
/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "Snipper" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Snipper"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {
	[self save];
}

-(void) save{
	NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	// Cleanup keyboard
	
	
    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}
-(void)closeWindow:(id)sender{
	[[NSApp keyWindow] close];
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 


@end
