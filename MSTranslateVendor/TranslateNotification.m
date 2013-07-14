//
//  TranslateNotification.m
//  MSTranslateVendorDemo
//
//  Created by SHIM MIN SEOK on 13. 7. 14..
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//

#import "TranslateNotification.h"

NSString * const kRequestTranslate       = @"requestTranslate";
NSString * const kRequestTranslateArray  = @"requestTranslateArray";
NSString * const kRequestDetectLanguage  = @"requestDetectLanguage";
NSString * const kRequestBreakSentences  = @"requestBreakSentences";

@implementation TranslateNotification

static TranslateNotification *sharedInstance = nil;
+ (TranslateNotification *)sharedObject
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    }
    return sharedInstance;
}

@end
