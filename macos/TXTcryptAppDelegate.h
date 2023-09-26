//
//  TXTcryptAppDelegate.h
//  TXTcrypt
//
//  Created by Vlad Alexa on 1/12/11.
//  Copyright 2011 NextDesign. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TXTcrypt;

@interface TXTcryptAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet TXTcrypt *txtcrypt;
}

@property (assign) IBOutlet NSWindow *window;

@end
