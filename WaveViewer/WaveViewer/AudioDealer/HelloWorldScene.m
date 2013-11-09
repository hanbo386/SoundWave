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

@implementation HelloWorld

@synthesize glWaveNode;

+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
    
    screenSize = [[CCDirector sharedDirector] winSize];
		//self.isTouchEnabled = YES;
    
    
    //创建http请求实例，并发起一次http请求，用于生成cookie文件以及服务端session
    Http *http = [[Http alloc] init];
    [http setRequest];
        
    //初始化socketIO，并设定代理
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    socketIO.cookie = http.cookie;
    [socketIO connectToHost:@"localhost" onPort:3000];
    //[socketIO connectToHost:@"192.168.1.2" onPort:3000 withCookie:http.cookie];
        
    //初始化JSONParser
    jsonParser = [[SBJsonParser alloc] init];
        
    		
		//
		CCSprite* sprite = [CCSprite spriteWithFile:@"head.png"];
		sprite.position =  ccp( screenSize.width / 2 , screenSize.height / 3 * 2 );
		sprite.anchorPoint = ccp(.5f,0.f);
		sprite.tag = kTagHead;
		[self addChild: sprite];
		
    waveStep = 0;
    currentI = 0;
    incresement = screenSize.width / (float)1;
    positionX = 0;
    [self createWave];
    //[self scheduleUpdate];
	}
	return self;
}


#pragma mark PowerLeverDidChange
//根据level的变化调整波形变化，此处level为均值而非峰值
-(void) avAvgPowerLevelDidChange:(float)level
{
    //	Just change the cocos2d logo scale for one channel
    [self getChildByTag:kTagHead].scale = 1 + level*.8f;
    
    //=========================
    // Setting shouldVaryAmplitude, shouldVaryFrequency and shouldVaryPhase to NO will stop the animation of the wave.
    //BOOL shouldVaryAmplitude = YES;
    
    //BOOL shouldVaryFrequency = YES;
    
    BOOL shouldVaryPhase = YES;
    
    
    variableFrequency = 3;
    variableAmplitude = level*30;
    
    
    // Change the wave phase over time.
    if (shouldVaryPhase == YES)
    {
        wavePhase += .03;
    }
    
  
    // Space the verticies out evenly across the screen for the wave.
    int oneWaveVertCount = waveVertCount / 30;
    float vertexHorizontalSpacing = screenSize.width / (float)waveVertCount;
    //float oneWave = screenSize.width / 30;//一个波的跨度
    //float vertexSpacing = oneWave / oneWaveVertCount;//
    
    // Used to increment to the next vertexX position.
    float currentWaveVertX = waveStep;
    
    NSInteger i ;
    for (i = 0; i < waveVertCount; i++)
    {
        
        float t = (float)i / (float)(oneWaveVertCount);
        float omega = 2 * M_PI * variableFrequency;
        float waveX, waveY;
        
        
        // For a sine wave, the formula is y(time) = magnitude x sin( 2 x Pi x frequency x time + phase).
        // The 2 x Pi x frequency can be replaced by the angular frequency, omega.
        // By dividing the time by waveVertCount and using the samples the wave is scaled to having the
        // wavelength of a 1hz signal equal to the width of the screen.
        // Check out Wikipedia for more details on sinusoids http://en.wikipedia.org/wiki/Sinusoid
        waveX = currentWaveVertX;
        waveY = variableAmplitude * (
                                     sinf(omega * t   + wavePhase)
                                     + sinf(omega * 0.5 * t + wavePhase * 2)
                                     + sinf(omega * 0.25 * t + wavePhase * 4)
                                     + sinf(omega * 0.125 * t + wavePhase * 8)
                                     + sinf(omega * 0.0625 * t + wavePhase * 16)
                                     + sinf(omega * 0.03125 * t + wavePhase * 32)
                                     + sinf(omega * 0.015625 * t + wavePhase * 64)
                                     + sinf(omega * 0.007831 * t + wavePhase * 128)
                                     )
        
        + 0.5 * screenSize.height;
        
        HeyaldaPoint p = [HeyaldaGLDrawNode hp3x:waveX y:waveY z:0];
        
        if (i >= positionX && i <= positionX + incresement)
        {
            //NSLog(@"i is %d, is %d", i, currentI+i);
            glWaveNode.dynamicVerts[i] = p;
        }
        
        currentWaveVertX += vertexHorizontalSpacing;
        
#define kWaveWithRandomColors 0
        
#if kWaveWithRandomColors
        
        red = (GLbyte)(CCRANDOM_0_1() * 255);
        green = (GLbyte)(CCRANDOM_0_1() * 255);
        blue = (GLbyte)(CCRANDOM_0_1() * 255);
        
        glWaveNode.dynamicVertColors[i] = ccc4(red, green, blue, 255);
#endif
        
    }
    positionX += incresement;
    if(positionX > screenSize.width)
        positionX = 0;
}

# pragma mark CreateWave

-(void) createWave
{
    // Create an instance of the HeyaldaGLDrawNode class and add it to this layer.
    glWaveNode = [[[HeyaldaGLDrawNode alloc] init] autorelease];
    
    [self addChild:glWaveNode z:1];
    
    // Set parameters that are used to define the shape of the siunsoid wave.
    wavefrequency = 2;
    waveAmplitude = 0;
    wavePhase = 0;
    waveVertCount = 1500;
    
    // Set the wave color.
    red = green = blue = 255;
    waveColor = ccc4(red, green,blue, 255);
    
    
    // Set the variables that are used to animate the wave in the update function.
    amplitudeDirection = 1;
    frequencyDirection = 1;
    variableFrequency = wavefrequency;
    variableAmplitude = waveAmplitude;
    
    
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    // Space the verticies out evenly across the screen for the wave.
    float vertexHorizontalSpacing = s.width / (float)waveVertCount;
    
    
    // Used to increment to the next vertexX position.
    float currentWaveVertX = 0;
    
    //int oneWaveVertCount  = waveVertCount / 30;
    //float vertexSpacing = s.width / 30 / oneWaveVertCount;
    for (NSInteger i = 0; i < waveVertCount; i++)
    {
        
        float time = (float)i;
        
        float waveX, waveY;
        
        waveX = currentWaveVertX;
        
        // Create the default sinusoid wave that will be displayed if the wave is not animated.
        waveY = variableAmplitude * sinf(2 * M_PI / (float)waveVertCount * wavefrequency * time + wavePhase) + 0.5 * s.height;
        
        //NSLog(@"time:%.2f waveAmplitude:%.2f Wave:%.2f,%2.f wavefrequency:%.2f",time, waveAmplitude, waveX, waveY, wavefrequency);
        [glWaveNode addToDynamicVerts2D:ccp(waveX,waveY) withColor:waveColor];
        
        currentWaveVertX += vertexHorizontalSpacing;
    }
    
    
    // Try experimenting with different draw modes to see the effect.
    //    glWaveNode.glDrawMode = kDrawPoints;
    glWaveNode.glDrawMode = kDrawLines;
    
    [glWaveNode setReadyToDrawDynamicVerts:YES];
    
}

//-(void) update:(ccTime) dt
//{
//    [av.beatTimer_ update:1];
//}

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
    //测试JSON格式数据能否被正确解析
    //NSLog(@"Json received %@", packet.data);
    NSDictionary *dic = [NSDictionary dictionary];
    dic =  [jsonParser objectWithString:packet.data];
    NSLog(@"Json received id:%@, name:%@, age: %d", [dic objectForKey:@"id"], [dic objectForKey:@"name"], [[dic objectForKey:@"age"] intValue]);
}
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic =  [jsonParser objectWithString:packet.data];
  
    //根据接收到的数据，来更新波形变化
    [self avAvgPowerLevelDidChange: [[[dic objectForKey:@"args"] objectAtIndex:0] floatValue]];
//    
//    SocketIOCallback cb = ^(id argsData) {
//        NSDictionary *response = argsData;
//        // do something with response
//        NSLog(@"ack arrived: %@", response);
//        
//        // test forced disconnect
//        //[socketIO disconnectForced];
//    };
    //[socketIO sendMessage:@"hello back!" withAcknowledge:cb];
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
