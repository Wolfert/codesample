//
//  QBAsyncConnection.m
//  QBism
//
//  Created by Wolfert de Kraker on 11/8/10.
//  Copyright 2010 ~. All rights reserved.
//

#import "QBAsyncConnection.h"
#import	"QBRequest.h"
#import "QBNetworkCheck.h"
#import "QBDataContainer.h"
#import "QBExceptionHandler.h"

/*---- Asynchrome verbinding ----
 
 Deze class is verantwoordelijk voor de uitwisseling van gegevens.
 
 1. men roept de public methode asynchronousFetcherWithRequest aan 
 2.	kijkt m.b.v QBNetworkCheck of er een internetverbinding beschikbaar is
 3. maakt het request object aan via QBRequest class
 4. maakt een instantie aan van NSURLConnecion. Een methode uit de foundation, deze implementeerd automatisch de methodes onder NSURLConnection methods
 
 */

@implementation QBAsyncConnection

@synthesize lv_pg;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark +
#pragma mark QBAsyncConnection public method

+ (id)asynchronousFetcherWithRequest:(NSMutableDictionary*)lv_jsonObject requestType:(int)lv_requestType delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	NSLog(@"----QBAsyncConnection init");
	id returnType;
    NSMutableURLRequest * request;
    
	if ([QBNetworkCheck checkInternet]) {
        request = [QBRequest buildRequest:lv_jsonObject requestType:lv_requestType];
        
		returnType = [[QBAsyncConnection alloc] initWithRequest:request
														delegate:aDelegate 
											   didFinishSelector:finishSelector 
												 didFailSelector:failSelector];
	} else {
        NSMutableDictionary *errorDet = [NSMutableDictionary dictionary];
        [errorDet setValue:@"Network connection unavailable" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"QPIT.SERVICE" code:100 userInfo:errorDet];
        [aDelegate performSelector:failSelector withObject:error];
		returnType = nil;
		NSLog(@"----QBAsyncConnection no connection available");
	}	
	return returnType;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark QBAsyncConnection instance methods

- (id)initWithRequest:(NSMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	if (self == [super init]){
		request = aRequest;
		delegate = aDelegate;
		didFinishSelector = finishSelector;
		didFailSelector = failSelector;
	}
	return self;
}

- (void)start
{
	NSLog(@"----QBAsyncConnection started");
	ShowNetworkActivityIndicator();
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		responseData = [NSMutableData data];
		NSLog(@"----QBAsyncConnection request sent");
	} else {
        [delegate performSelector:didFailSelector withObject:nil];
		HideNetworkActivityIndicator();
	}
	
}

- (void)cancel {
	if (connection) {
		[connection cancel];
		connection = nil;
		HideNetworkActivityIndicator();
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse 
{
    NSLog(@"Connection established");
	response = aResponse;
	[responseData setLength:0];
	
	if ([response isKindOfClass:[NSURLResponse self]]) 
    {
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		contentLength  = [[headers objectForKey:@"Content-Length"] intValue];
	}
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data 
{
	[responseData appendData:data];
	if(lv_pg){ 
		NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[responseData length]];
		lv_pg.progress = [resourceLength floatValue] / [[NSNumber numberWithInt:contentLength ] floatValue] + 0.1;
	}
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error 
{
	[delegate performSelector:didFailSelector
				   withObject:error];

	HideNetworkActivityIndicator();	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	NSLog(@"QBAsyncConnection did finish loading!");
    HideNetworkActivityIndicator();
	[delegate performSelector:didFinishSelector 
				   withObject:[QBRequest parseRequest:responseData]];
}

@end