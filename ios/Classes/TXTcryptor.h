//
//  TXTcryptor.h
//  TXTcryptor
//
//  Created by Vlad Alexa on 4/6/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface TXTcryptor : NSObject {
	
}

- (NSString *)encrypt:(NSString*)string password:(NSString*)password;
- (NSString *)decrypt:(NSString*)string password:(NSString*)password;
- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7;
- (NSString *)base64EncodeData:(NSData*)dataToConvert;
- (NSData*)base64DecodeString:(NSString *)string;

@end
