//
//  TXTcryptAppDelegate.m
//  TXTcrypt
//
//  Created by Vlad Alexa on 1/12/11.
//  Copyright 2011 NextDesign. All rights reserved.
//

#import "TXTcryptAppDelegate.h"

#import "VAValidation.h"
#import "txtcrypt.h"

@implementation TXTcryptAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	int v = [VAValidation v];		
	int a = [VAValidation a];
	if (v+a != 0)  {		
		exit(v+a);	
	}	
        
    [NSApp performSelectorInBackground:@selector(setServicesProvider:) withObject:txtcrypt];
    //[NSApp setServicesProvider:txtcrypt];
    //if ([NSApp servicesProvider] == NULL) NSLog(@"Error setting services.");   

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //clear badge so it does not remain in LaunchPad
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    [tile setBadgeLabel:nil];    
}

- (void)dealloc {
    [super dealloc];
}


@end
