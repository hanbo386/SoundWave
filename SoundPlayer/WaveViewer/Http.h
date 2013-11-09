//
//  http.h
//  WaveViewer
//
//  Created by game_design on 13-8-9.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//


@interface Http : NSObject <NSURLConnectionDataDelegate>{
    
    NSString *_cookie;
}
@property(assign, nonatomic) NSString *cookie;
-(void) setRequest;
@end
