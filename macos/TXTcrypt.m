//
//  TXTcrypt.m
//  TXTcryptX
//
//  Created by Vlad Alexa on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TXTcrypt.h"


@implementation TXTcrypt

CCOptions pad = 0;

-(void)printHex:(NSData*)data{
	NSMutableString *displayString = [[NSMutableString alloc] initWithCapacity:1];
	for (int i=0; i<[data length]; i++) {
		unsigned char uChar;
		[data getBytes:&uChar range:NSMakeRange(i, 1)];
		[displayString appendFormat:@"%02X ", uChar];
	}
	NSLog(@"%@",displayString);
	[displayString release];
}

- (void)TXTcryptCallback:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
    NSString *text = [pboard stringForType:NSStringPboardType];
    if (text) {
        [txtView setString:text];       
    }    
}

-(void)awakeFromNib{	
	
	//CFShow([NSSpeechSynthesizer availableVoices]);
	
	synth = [[NSSpeechSynthesizer alloc] initWithVoice:@"com.apple.speech.synthesis.voice.Alex"];
	
	//illustrate delegation, notifications, setters, bindings, key value observing, key value notifications 	
	
	//bind the badgeLabel property of dockTile to txtLength ivar of self
	NSDockTile *dockTile = [[NSApplication sharedApplication] dockTile];
	[dockTile bind:@"badgeLabel" toObject:self withKeyPath:@"txtLength" options:nil];
	/*-OR-*/	
	//bind in Interface Builder Bindings inspector	
	
	//observe the string property of txtView
	[txtView addObserver:self forKeyPath:@"string" options:NSKeyValueObservingOptionOld context:NULL];
        
    //disable wrapping entirely
    //[[txtView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    //[[txtView textContainer] setWidthTracksTextView:NO];
    //[txtView setHorizontallyResizable:YES];
	
}	

-(void)setLineBreakMode:(NSLineBreakMode)mode forView:(NSTextView*)view
{    
    NSTextStorage *storage = [view textStorage];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:mode];
    [storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [storage length])];
    [style release];
}

- (void)dealloc {
    [txtView removeObserver:self forKeyPath:@"stringValue"];
    [txtView release];
    [synth release];
    [super dealloc];
}

//NSKeyValueObserving notification 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == txtView){
        
        //change to NSLineBreakByCharWrapping
        [self setLineBreakMode:NSLineBreakByCharWrapping forView:txtView];   
        
        [self updateTextCount:txtView.string.length];        
	}	
}

//setter for the txtLength instance variable, generates KVO notifications
-(void)setTxtLength:(NSString *)string{	
	txtLength = string;
}

-(void)updateTextCount:(int)len
{
    //get the value of the length property and convert it from NSUinteger to NSString
    NSString *string = nil;
    if (len < 1000) {
        string = [NSString stringWithFormat:@"%i",len];            
    }else {
        string = [NSString stringWithFormat:@"%ik",len/1000];                        
    }
    
    //call the setter method of self to set txtLength with notifications
    [self setTxtLength:string];		
    
    /*-OR-*/
    
    //manually send the notifications and set the value
    //[self willChangeValueForKey:@"txtLength"];			
    //txtLength = string;		
    //[self didChangeValueForKey:@"txtLength"];	    
}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{   
    
    //factor the change in text length
    int len = txtView.string.length-affectedCharRange.length+[replacementString length];    
    [self updateTextCount:len];
    
    return YES;
}

#pragma mark NSControl delegate
- (void)controlTextDidChange:(NSNotification *)aNotification{ 

	NSString *string = [[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string];
	if ([aNotification object] == passField){
		//limit password to enforce Wassenaar Arrangement compliance	
		if (string.length > 8){	
			passField.stringValue = [passField.stringValue substringWithRange:NSMakeRange(0,8)];	
		}			
		[theScale setDoubleValue:passField.stringValue.length];	
	} else {
		//trigger KVO notification that txtField was changed
		[txtView willChangeValueForKey:@"stringValue"];				 
		[txtView didChangeValueForKey:@"stringValue"];		
		//or set the string value of a field to it's string value .. hell yea [txtField setStringValue:txtField.string];		
	}    
}

-(IBAction) speakButtonPressed:(id) sender{	
    if (synth) {
        if([synth isSpeaking]) [synth stopSpeaking];
        [synth startSpeakingString:txtView.string];
    }	
}

-(IBAction) cryptButtonPressed:(id) sender{	
	NSString *txtstring = txtView.string;
	NSString *password = [passField  stringValue];
	if ([password length] < 1) return;
	//trim password to enforce Wassenaar Arrangement compliance
	if ([password length] > 8){	
		password = [password substringWithRange:NSMakeRange(0,8)];	
	}
    NSData *encryptedResponse = [self doCipher:(NSData *)[txtstring dataUsingEncoding:NSUTF8StringEncoding] key:(NSData *)[password dataUsingEncoding:NSUTF8StringEncoding] context:kCCEncrypt padding:&pad];	
    NSString *result = [self base64EncodeData:encryptedResponse];
	[txtView setString:result];		
	//[self printHex:encryptedResponse];	
} 

-(IBAction) decryptButtonPressed:(id) sender{	
	NSString *txtstring = txtView.string;
	NSString *password = [passField stringValue];	
	//trim password to enforce Wassenaar Arrangement compliance
	if ([password length] > 8){	
		password = [password substringWithRange:NSMakeRange(0,8)];	
	}
    NSData *decryptedResponse = [self doCipher:[self base64DecodeString:txtstring] key:(NSData *)[password dataUsingEncoding:NSUTF8StringEncoding] context:kCCDecrypt padding:&pad];   
    NSString *result = [[NSString alloc] initWithData:decryptedResponse encoding:NSUTF8StringEncoding];
	[txtView setString:result];
	[result release];
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
    
    //LOGGING_FACILITY(plainText != nil, @"PlainText object cannot be nil." );
    //LOGGING_FACILITY(theSymmetricKey != nil, @"Symmetric key object cannot be nil." );
    //LOGGING_FACILITY(pkcs7 != NULL, @"CCOptions * pkcs7 cannot be NULL." );
    //LOGGING_FACILITY([theSymmetricKey length] == keysize, @"Disjoint choices for key size." );
    
    plainTextBufferSize = [plainText length];
    
    //LOGGING_FACILITY(plainTextBufferSize > 0, @"Empty plaintext passed in." );
    
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
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem creating the context, ccStatus == %d.", ccStatus );
    
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
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus );
    
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
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
    
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
