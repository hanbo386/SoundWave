// @see header
#import "AudioVisualization.h"
#import "SimpleAudioEngine.h"
//#import "CGPointExtension+More.h"

@implementation AudioVisualization
static AudioVisualization *sharedAV = nil;
@synthesize filterSmooth = filterSmooth_;

+(AudioVisualization *)sharedAV
{
	@synchronized(self)
    {
		if (!sharedAV)
			sharedAV = [[AudioVisualization alloc] init];
	}
	return sharedAV;
}

+(id)alloc
{
	@synchronized(self)
    {
		NSAssert(sharedAV == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

-(id)init {
	if((self = [super init]))
    {
		filterSmooth_ = AudioVisualization_FilterSmoothing;
		filteredPeak_ = 0;
		filteredAverage_ = 0;
		delegates_ = [[NSMutableArray alloc]initWithCapacity:2];
		
		avAvgPowerLevelSel_ = @selector(avAvgPowerLevelDidChange:channel:);
		avPeakPowerLevelSel_ = @selector(avPeakPowerLevelDidChange:channel:);
        
        scheduler = [[CCScheduler alloc] init];
        
        self.beatTimer_ = [CCTimer timerWithTarget:self selector:@selector(tick:) interval:1];

		[SimpleAudioEngine sharedEngine];
		if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
        {
            //CDLongAudioSource
			audioManager_ = [CDAudioManager sharedManager];
			AVAudioPlayer *bg = audioManager_.backgroundMusic.audioSourcePlayer;//========
			filteredPeak_ = malloc(bg.numberOfChannels * sizeof(double));
			filteredAverage_ = malloc(bg.numberOfChannels * sizeof(double));
			[self resetMetering];
		}
	}
	return self;
}

-(void)resetMetering
{
	AVAudioPlayer *bg = audioManager_.backgroundMusic.audioSourcePlayer;//=========================
	audioManager_.backgroundMusic.audioSourcePlayer.meteringEnabled = YES;//
	bzero(filteredPeak_, bg.numberOfChannels * sizeof(double));
	bzero(filteredAverage_, bg.numberOfChannels * sizeof(double));//原文件中此处有错误，注意改正
}

-(void)dealloc
{
	if(filteredPeak_)
		free(filteredPeak_);
	if(filteredAverage_)
		free(filteredAverage_);
	[delegates_ release];
	//[[CCScheduler sharedScheduler]unscheduleTimer:beatTimer_];//================================
    //[[[CCScheduler alloc] init] unscheduleSelector:@selector(beatTimer_) forTarget:self];//=======
    //[scheduler unscheduleSelector:@selector(tick) forTarget:self];
    //此处缺少。。。。。。。。。
	[super dealloc];
}


-(void)tick: (ccTime)dt
{
	if (!audioManager_) return;
	if (delegates_.count == 0) {
		return;
	}
	
	AVAudioPlayer *bg = audioManager_.backgroundMusic.audioSourcePlayer;//========
	
	if(![bg isPlaying]){
		return;
	}
	
	if(filteredPeak_ && filteredAverage_){
		[bg updateMeters];
		double peakPowerForChannel = 0.f,avgPowerForChannel = 0.f;
		for(ushort i = 0; i < bg.numberOfChannels; ++i){
			//	convert the -160 to 0 dB to [0..1] range
			peakPowerForChannel = pow(10, (0.05 * [bg peakPowerForChannel:i]));
			avgPowerForChannel = pow(10, (0.05 * [bg averagePowerForChannel:i]));
			
			filteredPeak_[i] = filterSmooth_ * peakPowerForChannel + (1.0 - filterSmooth_) * filteredPeak_[i];
			filteredAverage_[i] = filterSmooth_ * avgPowerForChannel + (1.0 - filterSmooth_) * filteredAverage_[i];
		}
		
		for(NSDictionary *delegate in delegates_)
        {
			if ([[delegate objectForKey:@"delegate"]respondsToSelector:avPeakPowerLevelSel_])
            {
				[[delegate objectForKey:@"delegate"]avPeakPowerLevelDidChange:filteredPeak_[[[delegate objectForKey:@"channel"] shortValue]] channel:[[delegate objectForKey:@"channel"] shortValue]];
			}
			if ([[delegate objectForKey:@"delegate"]respondsToSelector:avAvgPowerLevelSel_])
            {
				[[delegate objectForKey:@"delegate"]avAvgPowerLevelDidChange:filteredAverage_[[[delegate objectForKey:@"channel"] shortValue]] channel:[[delegate objectForKey:@"channel"] shortValue]];
			}
		}
	}
}

-(void)addDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort) channel
{
	if (!audioManager_) return;
	AVAudioPlayer *bg = audioManager_.backgroundMusic.audioSourcePlayer;//==========
	if(channel < bg.numberOfChannels){
		[delegates_ addObject:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", [NSNumber numberWithShort:channel], @"channel", nil]];
	}
}

-(void)removeDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort) channel
{
	if (!audioManager_) return;
	AVAudioPlayer *bg = audioManager_.backgroundMusic.audioSourcePlayer;//==========
	if(channel < bg.numberOfChannels){
		
		NSMutableArray *callbacksToRemove = [NSMutableArray new];
		for (NSDictionary *callback in delegates_){
			if([[callback valueForKey:@"delegate"] isEqual:delegate] && [[callback valueForKey:@"channel"] unsignedShortValue] == channel){
				[callbacksToRemove addObject:callback];
			}
		}
		
		for (NSDictionary *callback in callbacksToRemove){
			[delegates_ removeObject:callback];
		}
		
		[callbacksToRemove release];
	}
}

@end
