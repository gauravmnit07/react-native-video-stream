//
//  RCTPlayer.m
//  RCTPili
//
//  Created by buhe on 16/5/12.
//  Copyright © 2016年 pili. All rights reserved.
//

#import "RCTPlayer.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@interface RCTPlayer ()

@property (nonatomic, copy) RCTBubblingEventBlock onLoading;
@property (nonatomic, copy) RCTBubblingEventBlock onPaused;
@property (nonatomic, copy) RCTBubblingEventBlock onShutdown;
@property (nonatomic, copy) RCTBubblingEventBlock onStreamError;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaying;

@end

@implementation RCTPlayer{
    RCTEventDispatcher *_eventDispatcher;
    PLPlayer *_plplayer;
    bool _started;
    bool _muted;
}

static NSString *status[] = {
    @"PLPlayerStatusUnknow",
    @"PLPlayerStatusPreparing",
    @"PLPlayerStatusReady",
    @"PLPlayerStatusCaching",
    @"PLPlayerStatusPlaying",
    @"PLPlayerStatusPaused",
    @"PLPlayerStatusStopped",
    @"PLPlayerStatusError"
};


- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
        _started = YES;
        _muted = NO;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
         self.reconnectCount = 0;
    }
    
    return self;
};

- (void) setSource:(NSDictionary *)source
{
    NSString *uri = source[@"uri"];
    bool backgroundPlay = source[@"backgroundPlay"] == nil ? false : source[@"backgroundPlay"];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    
    // 更改需要修改的 option 属性键所对应的值
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    
    if(_plplayer){
        [_plplayer stop]; //TODO View 被卸载时 也要调用
    }

    _plplayer = [PLPlayer playerWithURL:[[NSURL alloc] initWithString:uri] option:option];

    _plplayer.delegate = self;
    _plplayer.delegateQueue = dispatch_get_main_queue();
    _plplayer.backgroundPlayEnable = backgroundPlay;
    if(backgroundPlay){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlayer) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    [self setupUI];
    
    [self startPlayer];
    
}

- (void)setupUI {
    if (_plplayer.status != PLPlayerStatusError) {
        // add player view
        UIView *playerView = _plplayer.playerView;
        [self addSubview:playerView];
         [playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:playerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:playerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:playerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        
        NSArray *constraints = [NSArray arrayWithObjects:centerX, centerY,width,height, nil];
        [self addConstraints: constraints];
    }
    
}

- (void) setStarted:(BOOL) started{
    if(started != _started){
    if(started){
        [_plplayer resume];
        _started = started;
    }else{
        [_plplayer pause];
        _started = started;
    }
    }
}

- (void) setMuted:(BOOL) muted {
    _muted = muted;
    [_plplayer setMute:muted];
    
}

- (void)startPlayer {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [_plplayer play];
    _started = true;
}

#pragma mark - <PLPlayerDelegate>

- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    //TODO - send event
    switch (state) {
        case PLPlayerStatusCaching:
            self.onLoading(@{@"target": self.reactTag});
            break;
        case PLPlayerStatusPlaying:
            self.onPlaying(@{@"target": self.reactTag});
            break;
        case PLPlayerStatusPaused:
            self.onPaused(@{@"target": self.reactTag});
            break;
        case PLPlayerStatusStopped:
            self.onShutdown(@{@"target": self.reactTag});
            break;
        case PLPlayerStatusError:
            self.onStreamError(@{@"target": self.reactTag});
            break;
        default:
            break;
    }
    NSLog(@"%@", status[state]);
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    [self tryReconnect:error];
}

- (void)tryReconnect:(nullable NSError *)error {
    if (self.reconnectCount < 3) {
        _reconnectCount ++;
        [_eventDispatcher sendInputEventWithName:@"onError" body:@{@"target": self.reactTag , @"errorCode": [NSNumber numberWithUnsignedInt:0]}];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * pow(2, self.reconnectCount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_plplayer play];
        });
    }else {
        [_eventDispatcher sendInputEventWithName:@"onError" body:@{@"target": self.reactTag , @"errorCode": [NSNumber numberWithUnsignedInt:0]}];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        NSLog(@"%@", error);
    }
}

@end
