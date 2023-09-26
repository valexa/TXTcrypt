//
//  TXTcryptor.m
//  TXTcryptor
//
//  Created by Vlad Alexa on 4/6/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "TXTcryptor.h"

static CCOptions pad= 0;

@implementation TXTcryptor

- (NSString *)encrypt:(NSString*)string password:(NSString*)password {	
	NSData *text = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *pass = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedResponse = [self doCipher:text key:pass context:kCCEncrypt padding:&pad];	
    return [self base64EncodeData:encryptedResponse];	
}

- (NSString *)decrypt:(NSString*)string password:(NSString*)password {
	NSData *pass = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedResponse = [self doCipher:[self base64DecodeString:string] key:pass context:kCCDecrypt padding:&pad];   
    return [[[NSString alloc] initWithData:decryptedResponse encoding:NSUTF8StringEncoding] autorelease];	
}

- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7
{
	//8 bit key size for Wassenaar Arrangement compliance	
#define keysize	    8
#define algorythm	kCCAlgorithmRC4		
	
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[keysize];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    if(plainText == nil)		NSLog(@"PlainText object cannot be nil.");
    if(theSymmetricKey == nil)  NSLog(@"Symmetric key object cannot be nil.");
    //if(pkcs7 == NULL)			NSLog(@"CCOptions * pkcs7 cannot be NULL.");
    //if([theSymmetricKey length] != keysize)  NSLog(@"Disjoint choices for key size.");
    if([theSymmetricKey length] > keysize)  NSLog(@"Too big key size.");	
    
    plainTextBufferSize = [plainText length];
	
	if (plainTextBufferSize < 1) NSLog(@"Empty plaintext passed in.");    
    
    // We don't want to toss padding on if we don't need to
    if(encryptOrDecrypt == kCCEncrypt)
    {
        if(*pkcs7 != kCCOptionECBMode)
        {
            if((plainTextBufferSize % kCCBlockSizeCAST) == 0)
            {
                *pkcs7 = 0x0000;
            }
            else
            {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
    }
    else if(encryptOrDecrypt != kCCDecrypt)
    {
        //LOGGING_FACILITY1( 0, @"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7 );
    } 
	
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate(    encryptOrDecrypt, 
                               algorythm, 
                               *pkcs7, 
                               (const void *)[theSymmetricKey bytes], 
                               [theSymmetricKey length], 
                               (const void *)iv, 
                               &thisEncipher
                               );
    
	if (ccStatus != kCCSuccess)	NSLog(@"Problem creating the context, ccStatus == %d.", ccStatus);
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate( thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
	if (ccStatus != kCCSuccess) NSLog(@"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus);
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(    thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher)
    {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
	if (ccStatus != kCCSuccess) NSLog(@"Problem with encipherment ccStatus == %d", ccStatus);	
    
    cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
	
}


- (NSString *)base64EncodeData:(NSData*)dataToConvert
{
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";	
    if ([dataToConvert length] == 0) return @"";
    
    char *characters = malloc((([dataToConvert length] + 2) / 3) * 4);
    if (characters == NULL) return nil;
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [dataToConvert length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [dataToConvert length])
            buffer[bufferLength++] = ((char *)[dataToConvert bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';    
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

- (NSData*)base64DecodeString:(NSString *)string
{
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";	
    if (string == nil) [NSException raise:NSInvalidArgumentException format:@"String to b64 decode is nil"];
    if ([string length] == 0) return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSUTF8StringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    realloc(bytes, length);
    
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

@end
