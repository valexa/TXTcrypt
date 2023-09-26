//
//  TXTcrypt.h
//  TXTcryptX
//
//  Created by Vlad Alexa on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

@interface TXTcrypt : NSObject <NSTextViewDelegate>{

	IBOutlet NSLevelIndicator	*theScale;
	IBOutlet NSSecureTextField	*passField;			
	IBOutlet NSButton		*encryptButton;
	IBOutlet NSButton		*decryptButton;
	IBOutlet NSTextView		*txtView;		
	NSString *txtLength;
	NSSpeechSynthesizer	*synth;
	
}


-(void)printHex:(NSData*)data;
- (void)TXTcryptCallback:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
-(IBAction) speakButtonPressed:(id) sender;
-(IBAction) cryptButtonPressed:(id) sender;
-(IBAction) decryptButtonPressed:(id) sender;
- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7;
- (NSString *)base64EncodeData:(NSData*)dataToConvert;
- (NSData*)base64DecodeString:(NSString *)string;
-(void)setTxtLength:(NSString *)string;

@end
