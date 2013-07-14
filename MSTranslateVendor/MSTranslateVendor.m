//
//  MSTranslateVendor.m
//  MSTranslateVendor
//
//  Created by SHIM MIN SEOK on 13. 1. 14..
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//

#import "MSTranslateVendor.h"
#import "MSTranslateAccessTokenRequester.h"
#import "NSMutableURLRequest+WebServiceExtend.h"
#import "NSString+Extend.h"
#import "NSXMLParser+Taged.h"
#import "TranslateNotification.h"

@interface MSTranslateVendor()
{
    NSMutableData *_responseData;
    NSMutableURLRequest *_request;
    NSString *_elementString;
    NSMutableArray *_attributeCollection;
    NSMutableArray *_translatedArray;
    NSMutableDictionary *_sentencesDict;
    NSUInteger _sentenceCount;
}
@end

@implementation MSTranslateVendor

typedef enum
{
    REQUEST_TRANSLATE_TAG,
    REQUEST_TRANSLATE_ARRAY_TAG,
    REQUEST_DETECT_TEXT_TAG,
    REQUEST_BREAKSENTENCE_TAG
}ParserTag;

#pragma mark - C functions

NSString * generateSchema(NSString *);

NSString * generateSchema(NSString * text)
{
    return [NSString stringWithFormat:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">%@</string>", text];
}

#pragma mark - Microsoft Translate Method

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
    
    if([TranslateNotification sharedObject].translateNotification)
    {
        [TranslateNotification sharedObject].translateNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestTranslate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                                 {
                                     if([noti.object[@"isSuccessful"] boolValue])
                                     {
                                         successBlock(noti.object[@"result"]);
                                     }
                                     else
                                     {
                                         failureBlock(noti.object[@"result"]);
                                     }
                                     
                                     [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].translateNotification];
                                     [TranslateNotification sharedObject].translateNotification = nil;
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
         _parser.tag = REQUEST_TRANSLATE_TAG;
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

- (void)requestTranslateArray:(NSArray *)translateArray
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    [self requestTranslateArray:translateArray from:nil to:to blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestTranslateArray:(NSArray *)translateArray
                         from:(NSString *)from
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    if(![TranslateNotification sharedObject].translateArrayNotification)
    {
        [TranslateNotification sharedObject].translateArrayNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestTranslateArray object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                                                                        {
                                                                            if([noti.object[@"isSuccessful"] boolValue])
                                                                            {
                                                                                successBlock(noti.object[@"result"]);
                                                                            }
                                                                            else
                                                                            {
                                                                                failureBlock(noti.object[@"result"]);
                                                                            }
                                                                            
                                                                            [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].translateArrayNotification];
                                                                            [TranslateNotification sharedObject].translateArrayNotification = nil;
                                                                        }];
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken];

    NSMutableString *schemaCollection = [@"" mutableCopy];
    for (NSString *text in translateArray)
    {
        [schemaCollection appendFormat:@"%@\n", generateSchema(text)];
    }
    
    NSString *xmlString = [NSString stringWithFormat:@"<TranslateArrayRequest>\n\
    <AppId />\n\
    %@\n\
    <Options>\n\
    <Category xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\" />\n\
    <ContentType xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\">text/plain</ContentType>\n\
    <ReservedFlags xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\" />\n\
    <State xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\" />\n\
    <Uri xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\" />\n\
    <User xmlns=\"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2\" />\n\
    </Options>\n\
    <Texts> %@ </Texts>\n\
    <To>%@</To>\n\
    </TranslateArrayRequest>", from?[NSString stringWithFormat:@"<From>%@</From>",from]:@"", schemaCollection, to];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:0 error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:xmlString options:0 range:NSMakeRange(0, [xmlString length]) withTemplate:@" "];
    
    NSURL *requestURL = [NSURL URLWithString:@"http://api.microsofttranslator.com/v2/Http.svc/TranslateArray"];
    
    [_request setURL:[requestURL standardizedURL]];
    [_request setHTTPMethod:@"POST"];
    [_request setHTTPBody:[result dataUsingEncoding:NSUTF8StringEncoding]];
    [_request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:_appId forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_TRANSLATE_ARRAY_TAG;
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
    if(![TranslateNotification sharedObject].detectNotification)
    {
        [TranslateNotification sharedObject].detectNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestDetectLanguage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].detectNotification];
                                  [TranslateNotification sharedObject].detectNotification = nil;
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
         _parser.tag = REQUEST_DETECT_TEXT_TAG;
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
    
    if(![TranslateNotification sharedObject].breakSentencesNotification)
    {
        [TranslateNotification sharedObject].breakSentencesNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestBreakSentences object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].breakSentencesNotification];
                                  [TranslateNotification sharedObject].breakSentencesNotification = nil;
                              }];
    }
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];

    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/BreakSentences?appId=%@&text=%@&language=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], language];
       
    NSURL *uri = [NSURL URLWithString:uriString];
        
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_BREAKSENTENCE_TAG;
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
    _translatedArray = [@[] mutableCopy];
    _sentencesDict = [@{} mutableCopy];
    _sentenceCount = 1;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _responseData = nil;
    
    if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([_translatedArray count])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslateArray object:@{@"result" : _translatedArray, @"isSuccessful": @YES}];
        }
    }
    if(parser.tag == REQUEST_BREAKSENTENCE_TAG)
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
    if(parser.tag == REQUEST_TRANSLATE_TAG)
    {
        if([_elementString isEqualToString:@"string"])
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : string, @"isSuccessful": @YES}];
        else if([_elementString isEqualToString:@"h1"])
        {
            if([string isEqualToString:@"Argument Exception"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Argument Exception" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-3 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
        else if([_elementString isEqualToString:@"p"])
        {
            if([string isEqualToString:@"Invalid appId"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Invalid appId" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-4 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }

    }
    else if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([_elementString isEqualToString:@"TranslatedText"])
        {
            [_translatedArray addObject:string];
        }
    }
    else if(parser.tag == REQUEST_DETECT_TEXT_TAG)
    {
        if([_elementString isEqualToString:@"string"])
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : string, @"isSuccessful": @YES}];
        else if([_elementString isEqualToString:@"h1"])
        {
            if([string isEqualToString:@"Argument Exception"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Argument Exception" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-3 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
        else if([_elementString isEqualToString:@"p"])
        {
            if([string isEqualToString:@"Invalid appId"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Invalid appId" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-4 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
        else if([_elementString isEqualToString:@"int"])
        {
            [_sentencesDict setValue:string forKey:[NSString stringWithFormat:@"%d", _sentenceCount]];
            
            _sentenceCount ++;
        }
    }
}

@end