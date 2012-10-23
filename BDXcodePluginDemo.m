//
//  BDXcodePluginDemo.m
//  BDXcodePluginDemo
//
//  Created by Craig Edwards on 22/10/12.
//  Copyright (c) 2012 BlackDog Foundry. All rights reserved.
//

#import "BDXcodePluginDemo.h"

@implementation NSView (Dumping)

-(void)dumpWithIndent:(NSString *)indent {
	NSString *clazz = NSStringFromClass([self class]);
	NSString *info = @"";
	if ([self respondsToSelector:@selector(title)]) {
		NSString *title = [self performSelector:@selector(title)];
		if (title != nil && [title length] > 0)
			info = [info stringByAppendingFormat:@" title=%@", title];
	}
	if ([self respondsToSelector:@selector(stringValue)]) {
		NSString *string = [self performSelector:@selector(stringValue)];
		if (string != nil && [string length] > 0)
			info = [info stringByAppendingFormat:@" stringValue=%@", string];
	}
	NSString *tooltip = [self toolTip];
	if (tooltip != nil && [tooltip length] > 0)
		info = [info stringByAppendingFormat:@" tooltip=%@", tooltip];
	
	NSLog(@"%@%@%@", indent, clazz, info);
	
	if ([[self subviews] count] > 0) {
		NSString *subIndent = [NSString stringWithFormat:@"%@%@", indent, ([indent length]/2)%2==0 ? @"| " : @": "];
		for (NSView *subview in [self subviews])
			[subview dumpWithIndent:subIndent];
	}
}

@end

@implementation BDXcodePluginDemo

#
#pragma mark - Lifecycle management
#
static BDXcodePluginDemo *mySharedPlugin = nil;

+(void)pluginDidLoad:(NSBundle *)plugin {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mySharedPlugin = [[self alloc] init];
	});
}

+(BDXcodePluginDemo *)sharedPlugin {
	return mySharedPlugin;
}

-(id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationListener:) name:nil object:nil];
		[self addMenuItems];
	}
	return self;
}

#
#pragma mark - Dumping notifications
#
-(void)notificationListener:(NSNotification *)notification {
	// let's filter all the "normal" NSxxx events so that we only
	// really see the Xcode specific events.
	if ([[notification name] length] >= 2 && [[[notification name] substringWithRange:NSMakeRange(0, 2)] isEqualTo:@"NS"])
		return;
	else {
		NSLog(@"  Notification: %@", [notification name]);
	}
}

#
#pragma mark - Manipulating menus
#
-(void)addMenuItems {
	// this method adds a new item to the Edit menu, and also creates a new
	// menu called Demo with a single menu item.  Be careful when searching for
	// the menus by title because Xcode may have localised the title. You may
	// be better using, say, [mainMenu itemAtIndex:2]
	NSMenu *mainMenu = [NSApp mainMenu];
	
	// find the Edit menu and add a new item
	NSMenuItem *editMenu = [mainMenu itemWithTitle:@"Edit"];
	NSMenuItem *item1 = [[NSMenuItem alloc] initWithTitle:@"Click me 1" action:@selector(click1:) keyEquivalent:@""];
	[item1 setTarget:self];
	[[editMenu submenu] addItem:item1];

	// create a new menu and add a new item
	NSMenu *demoMenu = [[NSMenu alloc] initWithTitle:@"Demo"];
	NSMenuItem *item2 = [[NSMenuItem alloc] initWithTitle:@"Click me 2" action:@selector(click2:) keyEquivalent:@""];
	[item2 setTarget:self];
	[demoMenu addItem:item2];
	// add the newly created menu to the main menu bar
	NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Demo" action:NULL keyEquivalent:@""];
	[newMenuItem setSubmenu:demoMenu];
	[mainMenu addItem:newMenuItem];
}

-(void)click1:(id)sender {
	NSLog(@"Menu item 1 clicked");
}

-(void)click2:(id)sender {
	NSLog(@"Menu item 2 clicked");
	[self dumpWindow];
}

#
#pragma mark - Finding controls
#
-(void)dumpWindow {
	[[[NSApp mainWindow] contentView] dumpWithIndent:@""];
}

#
#pragma mark - Cleanup
#
-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
