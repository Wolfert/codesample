//
//  QBAsyncConnection.h
//  QBism
//
//  Created by Wolfert de Kraker on 11/8/10.
//  Copyright 2010 ~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QBProgressIndicator.h"

@interface QBAsyncConnection : NSObject {
    NSMutableURLRequest *request;
    NSURLResponse       *response;
    NSURLConnection     *connection;
    NSMutableData       *responseData;
	
    QBProgressIndicator *lv_pg;
    
    id      delegate;
    SEL     didFinishSelector;
    SEL     didFailSelector;
	int     contentLength;
}

@property (nonatomic, strong) QBProgressIndicator * lv_pg;

+ (id)asynchronousFetcherWithRequest:(NSMutableDictionary*)lv_jsonObject requestType:(int)lv_requestType delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (id)initWithRequest:(NSMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

- (void) start;
- (void) cancel;

@end