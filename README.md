MSTranslateVendor
=================

Microsoft Translate iOS API

Microsoft ends free Bing Search API, moves to paid service on Azure Marketplace. Bing translator is deprecated, and it forces developers to use a more complicated way than the previous way using AppID.

The Microsoft Translate new API involves a temporal token, named as access token, which will expire in 10 minutes after you get it. before you get a token, your application must be registered.

Please refer to the steps below.(Microsoft Azure Market Join step is omitted.) 

(1) access https://datamarket.azure.com/developer/applications and register the client application (that is, the app using the API), where you can create your own Client ID and Name, and you also have to type in
redirect URI which should be a valid URL address (like "http://www.....");
  
![](https://s3.amazonaws.com/Y1J8k27YH1U3r6LeEwCOP2cvY97xxXTs/img0.png)

(2) If you complete the registration, the following screen appears. 
  
![](https://s3.amazonaws.com/Y1J8k27YH1U3r6LeEwCOP2cvY97xxXTs/img1.png)

For more information: http://msdn.microsoft.com/en-us/library/hh454950.aspx

## Installation ##

Drag the included MSTranslateVendor folder into your project.

## Usage ##

In <b>`MSTranslateAccessTokenRequester.h`</b> `CLIENT_ID`, `CLIENT_SECRET` must change to Client id and Client secret your registered applications. refer a above image.

    #define CLIENT_ID       @""
    #define CLIENT_SECRET   @""

These classes was written under the ARC. Be sure to specify `-fobjc-arc` the 'Compile Sources' Build Phase for each file if you aren't using ARC project-wide

## Sample Code ##

    #import "MSTranslateAccessTokenRequester.h"
    #import "MSTranslateVendor.h"
    
    //Must be called before used to MSTranslateVendor
    [[MSTranslateAccessTokenRequester sharedRequester] requestSynchronousAccessToken:CLIENT_ID clientSecret:CLIENT_SECRET];
    
    MSTranslateVendor *vendor = [[MSTranslateVendor alloc] init];
    [vendor requestTranslate:@"독도는 대한민국 영토 입니다." from:@"ko" to:@"en" blockWithSuccess:
     ^(NSString *translatedText)
    {
        NSLog(@"translatedText: %@", translatedText);
    }
    failure:^(NSError *error)
    {
        NSLog(@"error_translate: %@", error);
    }];
    
    [vendor requestDetectTextLanguage:@"독도는 대한민국 영토 입니다." blockWithSuccess:
     ^(NSString *language)
    {
        NSLog(@"language:%@", language);
    }
    failure:
     ^(NSError *error)
    {
        NSLog(@"error_detect: %@", error);
    }];
    
    [vendor requestSpeakingText:@"Dokdo is korean territory." language:@"en" blockWithSuccess:
     ^(NSData *streamData)
     {
         NSError *error;
         self.player = [[AVAudioPlayer alloc] initWithData:streamData error:&error];
         [_player play];
     }
     failure:
     ^(NSError *error)
     {
         NSLog(@"error_speak: %@", error);
     }];
     
    [vendor requestBreakSentences:@"Dokdo est un territoire de la République de Corée. Géographiquement situé dans l'est de la République de Corée.
                                     Historiquement, géographiquement Vonage Dokdo est clairement le territoire de la République de Corée." 
                                     language:@"fr" blockWithSuccess:
     ^(NSDictionary *sentencesDict)
     {
        NSLog(@"sentences_dict:%@", sentencesDict);
     }
     failure:^(NSError *error)
     {
        
     }];


## License ##

Software License Agreement (BSD License)

Copyright (c) 2013 Minseok Shim. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.

  3. Neither the name of Infrae nor the names of its contributors may
     be used to endorse or promote products derived from this software
     without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL INFRAE OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Contact ##

bitmapdata.com@gmail.com
