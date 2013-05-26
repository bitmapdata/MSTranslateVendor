//
//  MSTranslateVendor.m
//  MSTranslateVendor
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "MSTranslateVendor.h"
#import "MSTranslateAccessTokenRequester.h"
#import "NSMutableURLRequest+WebServiceExtend.h"
#import "NSString+Extend.h"
#import "NSXMLParser+Taged.h"

@interface MSTranslateVendor()
{
    NSMutableData *_responseData;
    NSMutableURLRequest *_request;
    NSString *_elementString;
    NSMutableArray *_attributeCollection;
    id translateNotification;
    id detectNotification;
    id breakSentencesNotification;
    NSMutableDictionary *_sentencesDict;
    NSUInteger sentenceCount;
}
@end

@implementation MSTranslateVendor

NSString * const kRequestTranslate       = @"requestTranslate";
NSString * const kRequestDetectLanguage  = @"requestDetectLanguage";
NSString * const kRequestBreakSentences  = @"requestBreakSentences";

- (void)requestTranslate:(NSString *)text
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock
{
    [self requestTranslate:text from:nil to:to blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestTranslate:(NSString *)text
                    from:(NSString *)from
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock
{
    
    if(!translateNotification)
    {
        translateNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestTranslate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                                 {
                                     if([noti.object[@"isSuccessful"] boolValue])
                                     {
                                         successBlock(noti.object[@"result"]);
                                     }
                                     else
                                     {
                                         failureBlock(noti.object[@"result"]);
                                     }
                                     
                                     [[NSNotificationCenter defaultCenter] removeObserver:translateNotification];
                                     translateNotification = nil;
                                 }];
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];

    NSString *uriString = NULL;
    if(from)
    {
           uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&from=%@&to=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], from, to];
    }
    else
    {
           uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&to=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],to];
    }
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = 1;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }
     }];
}

- (void)requestDetectTextLanguage:(NSString *)text
                 blockWithSuccess:(void (^)(NSString *language))successBlock
                          failure:(void (^)(NSError *error))failureBlock
{
    if(!detectNotification)
    {
        detectNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestDetectLanguage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:detectNotification];
                                  detectNotification = nil;
                              }];
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];
    
    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Detect?appId=%@&text=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = 2;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }

     }];
}

- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock
{
    [self requestSpeakingText:text language:language audioFormat:MP3_FORMAT blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
                audioFormat:(MSRequestAudioFormat)requestAudioFormat
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock
{
    NSString *content_type;
    switch (requestAudioFormat)
    {
        case MP3_FORMAT:
            content_type = @"audio/wav";
            break;
        case WAV_FORMAT:
            content_type = @"audio/mp3";
            break;
        default:
            content_type = @"audio/mp3";
            break;
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];
    
    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Speak?appId=%@&text=%@&language=%@&format=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], language, content_type];
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         successBlock(data);
         
         if(error)
         {
             failureBlock(error);
         }
     }];
}

- (void)requestBreakSentences:(NSString *)text
                     language:(NSString *)language
             blockWithSuccess:(void (^)(NSDictionary *sentencesDict))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    
    if(!breakSentencesNotification)
    {
        breakSentencesNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestBreakSentences object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:detectNotification];
                                  detectNotification = nil;
                              }];
    }
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];

    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/BreakSentences?appId=%@&text=%@&language=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], language];
       
    NSURL *uri = [NSURL URLWithString:uriString];
        
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = 3;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }
     }];
}

#pragma mark - NSXMLParser Delegate

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _elementString = NULL;
    _attributeCollection = [@[] mutableCopy];
    _sentencesDict = [@{} mutableCopy];
    sentenceCount = 1;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _responseData = nil;
    
    if(parser.tag == 3)
    {
        if([[_sentencesDict allKeys] count])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestBreakSentences object:@{@"result" : _sentencesDict, @"isSuccessful": @YES}];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _elementString = [elementName copy];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([_elementString isEqualToString:@"string"])
    {
        if(parser.tag == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : string, @"isSuccessful": @YES}];
        }
        else if(parser.tag == 2)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : string, @"isSuccessful": @YES}];
        }
    }
    else if([_elementString isEqualToString:@"h1"])
    {
        if([string isEqualToString:@"Argument Exception"])
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Argument Exception" forKey:NSLocalizedFailureReasonErrorKey];
            NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-3 userInfo:errorInfo];
            
            if(parser.tag == 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
            else if(parser.tag == 2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
    }
    else if([_elementString isEqualToString:@"p"])
    {
        if([string isEqualToString:@"Invalid appId"])
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Invalid appId" forKey:NSLocalizedFailureReasonErrorKey];
            NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-4 userInfo:errorInfo];
            
            if(parser.tag == 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
            else if(parser.tag == 2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
    }
    else if([_elementString isEqualToString:@"int"])
    {
        [_sentencesDict setValue:string forKey:[NSString stringWithFormat:@"%d", sentenceCount]];
        
        sentenceCount ++;
    }
}

@end