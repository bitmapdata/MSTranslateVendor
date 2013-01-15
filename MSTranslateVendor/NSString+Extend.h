//
//  NSString+Extend.h
//  MSTranslateVendor
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag;
- (BOOL)containsString:(NSString *)aString;
- (NSString *)urlEncodedUTF8String;
@end
