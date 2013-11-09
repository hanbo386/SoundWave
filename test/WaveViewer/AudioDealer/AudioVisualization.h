//
//  AudioVisualization.h
//  Silhouette
//
//  Created by Lam Pham on 1/21/10.
//  Copyright 2010 FancyRatStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol AudioVisualizationProtocol
@optional
-(void)avAvgPowerLevelDidChange:(float)level channel:(ushort)aChannel;
-(void)avPeakPowerLevelDidChange:(float)level channel:(ushort)aChannel;
@end

#define AudioVisualization_FilterSmoothing 0.2f
@class CDAudioManager;
@interface AudioVisualization : NSObject
{
	//	weak reference
	CDAudioManager	*audioManager_;
	
	double			filterSmooth_;
	double			*filteredPeak_;
	double			*filteredAverage_;
	CCTimer			*beatTimer_;
	NSMutableArray	*delegates_;
	SEL				avAvgPowerLevelSel_;
	SEL				avPeakPowerLevelSel_;
    
    CCScheduler* scheduler;
}

@property (nonatomic, retain) CCTimer* beatTimer_;
///
//	Smoothing factor from [0..1]
///
@property double filterSmooth;

/// 
//	returns the shared instance
///
+(AudioVisualization*)sharedAV;

///
//	@params seconds is the interval delay
///
-(void)setMeteringInterval:(float) seconds;

///
//	If background music is ever reloaded with a new song then you should call 
//	reset metering
///
-(void)resetMetering;

-(void)addDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort)channel;
-(void)removeDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort) channel;
@end
