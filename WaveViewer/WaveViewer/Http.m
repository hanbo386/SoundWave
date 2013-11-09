//
//  http.m
//  WaveViewer
//
//  Created by game_design on 13-8-9.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "Http.h"


@implementation Http

@synthesize cookie = _cookie;

-(id)init
{
    if(self = [super init])
    {
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

-(void) setRequest
{
    //NSLog(@"start");
    //此处localhost需要被替换
    NSString *urlString = [NSString stringWithFormat:@"http://localhost/todo/stats/wave/msbhb1"];
    //NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.2:3000/todo/stats/wave/msbhb2"];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"get"];
    
    //set headers
    NSString *contentType = [NSString stringWithFormat:@"text/html"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //set body
    //发送一个空body
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@""] dataUsingEncoding:NSUTF8StringEncoding]];
    //[postBody appendData:[[NSString stringWithFormat:@"<xml>"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
  
    //发起一次同步http连接请求，从response中提取cookie
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
  
    NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*) response;
    NSDictionary *fields = [httpRes allHeaderFields];
    self.cookie = [fields valueForKey:@"Set-Cookie"];
    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cooki in [cookieJar cookies]) {
//        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxx%@", cooki);
//    }
//    cookie = @"fasfasdfasdfas";
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error){
//        if(error)
//        {
//            NSLog(@"An error occured: %@", error);
//        }
//        else
//        {
//            
//        }
//        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        
//        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
//        NSLog(@"getJson: %d", [[dataDic objectForKey:@"id"] intValue]);
//        NSLog(@"get: %@", dataStr);
//    }];
//    [operationQueue release];
}
@end
