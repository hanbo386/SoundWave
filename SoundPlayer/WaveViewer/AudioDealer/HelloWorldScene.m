//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "SimpleAudioEngine.h"
#import "SimpleAudioEngine.h"
#import "Http.h"
//#import "DebugAudioVis.h"

enum {
	kTagBg,
	kTagHead,
};

float waveStep;
int currentI;
float incresement;
float positionX;
BOOL isBGPaused;

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
    
    Http *http = [[Http alloc] init];
    [http setRequest];
        
    //初始化socketIO，并设定代理
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    socketIO.cookie = http.cookie;
    //[socketIO connectToHost:@"localhost" onPort:3000];
    [socketIO connectToHost:@"192.168.1.5" onPort:3000];
        
    //初始化JSONParser
    jsonParser = [[SBJsonParser alloc] init];
        
		// ask director the the window size
		sceenSize = [[CCDirector sharedDirector] winSize];
		
		self.isTouchEnabled = YES;
    [self scheduleUpdate];
	}
	return self;
}
- (void) dealloc
{
	[super dealloc];
}

-(void) update:(ccTime) dt
{
  [av.beatTimer_ update:1];
}

//==========播放音乐============//
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
    {
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        isBGPaused = YES;
	}
    else
    {
        if(isBGPaused)
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        else
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"BC.mp3" loop:YES];
            
            //	Now let's setup audio visualization
            //	We should always call AudioVisualization AFTER we load the background music
            //	We add a delegate callback for each audio channel, there's 2
            //	As the metering of our audio runs it returns a level value form 0..1
            av = [AudioVisualization sharedAV];
            [av addDelegate:self forChannel:0];
            
            [[AudioVisualization sharedAV] resetMetering];
        }
	}
    
}
#pragma mark PowerLeverDidChange
//回调函数，每次音乐数据发生变化，向服务器发送一次
- (void) avAvgPowerLevelDidChange:(float) level channel:(ushort) theChannel
{
    [socketIO sendEvent:@"welcom" withData:[NSNumber numberWithFloat:level]];
}

- (void) avPeakPowerLevelDidChange:(float) level channel:(ushort) aChannel
{
}

# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"Message received");
}
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic =  [jsonParser objectWithString:packet.data];
}
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}


@end
