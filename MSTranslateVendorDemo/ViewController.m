//
//  ViewController.m
//  MSTranslateVendorDemo
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "ViewController.h"
#import "MSTranslateAccessTokenRequester.h"
#import "MSTranslateVendor.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
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
        NSLog(@"error: %@", error);
    }];
    
    [vendor requestDetectTextLanguage:@"독도는 대한민국 영토 입니다." blockWithSuccess:
     ^(NSString *language)
    {
        NSLog(@"language:%@", language);
    }
    failure:
     ^(NSError *error)
    {
        
    }];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
