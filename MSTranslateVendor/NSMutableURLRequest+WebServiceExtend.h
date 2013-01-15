//
//  NSMutableURLRequest+WebServiceExtend.h
//  MSTranslateVendor
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (WebServiceExtend)
+ (NSString *)encodeFormPostParameters: (NSDictionary *)parameters;
- (void)setFormPostParameters: (NSDictionary *)parameters;
@end
