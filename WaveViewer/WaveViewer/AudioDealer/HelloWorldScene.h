
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "AudioVisualization.h"
#import "HeyaldaGLDrawNode.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "SBJson.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer <AudioVisualizationProtocol, SocketIODelegate>
{
    SocketIO *socketIO;
    SBJsonParser *jsonParser;
    
    AudioVisualization* av;
    
    float waveTime;
    
    // A CCNode subclass that simplifies drawing lines, points, triangle strips, and triangle fan geometery.
    HeyaldaGLDrawNode* glWaveNode;
    
    // Properties of the sinusoidal wave that is created to simulate something like an audio signa.
    NSUInteger         waveVertCount;
    float              wavefrequency;
    float              waveAmplitude;
    float              wavePhase;
    ccColor4B          waveColor;
    
    // Values used to changed in the update: method to alter the shape of the siusoidal wave that is drawn.
    float               variableFrequency;
    float               variableAmplitude;
    float               amplitudeDirection;
    float               frequencyDirection;
    
    GLbyte              red;
    GLbyte              green;
    GLbyte              blue;
    
    CGSize screenSize;
}

@property (nonatomic, retain)  HeyaldaGLDrawNode* glWaveNode;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(void) createWave;
-(void) avAvgPowerLevelDidChange:(float)level;
@end
