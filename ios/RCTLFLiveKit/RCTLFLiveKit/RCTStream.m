//
//  RCTStream.m
//  RCTLFLiveKit
//
//  Created by 권오빈 on 2016. 8. 10..
//  Copyright © 2016년 권오빈. All rights reserved.
//

#import <React/RCTBridge.h>
#import "LFLiveSession.h"
//#import <LFLiveKit/LFLiveSession.h>
#import "RCTStream.h"
#import "RCTStreamManager.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@interface RCTStream () <LFLiveSessionDelegate>

@property (nonatomic, weak) RCTStreamManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *startLiveButton;

@property (nonatomic, copy) RCTBubblingEventBlock onReady;
@property (nonatomic, copy) RCTBubblingEventBlock onPending;
@property (nonatomic, copy) RCTBubblingEventBlock onStart;
@property (nonatomic, copy) RCTBubblingEventBlock onStreamError;
@property (nonatomic, copy) RCTBubblingEventBlock onStreamingStopped;

@end

@implementation RCTStream{
    bool _started;
    bool _cameraFronted;
    NSString *_url;
    NSDictionary *_videoConfig;
    NSDictionary *_audioConfig;
    bool _landscape;
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
    [self insertSubview:view atIndex:atIndex + 1];
    return;
}

- (void)removeReactSubview:(UIView *)subview
{
    [subview removeFromSuperview];
    return;
}

- (void)removeFromSuperview
{
    __weak typeof(self) _self = self;
    if(!_started){
        [_self.session stopLive];
    }
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    //[UIApplication sharedApplication].idleTimerDisabled = _previousIdleTimerDisabled;
}

- (id) initWithManager:(RCTStreamManager *)manager bridge:(RCTBridge *)bridge{
    if ((self = [super init])) {
        _started = NO;
        _cameraFronted = YES;
        self.manager = manager;
        self.bridge = bridge;
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
//
//        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
//        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
//        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
//
//        NSArray *constraints = [NSArray arrayWithObjects:centerX, centerY,width,height, nil];
//        [self addConstraints: constraints];

        //[self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark -- Public Method
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问

            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
        case LFLiveReady:
            self.onReady(@{@"target": self.reactTag});
            break;
        case LFLivePending:
            self.onPending(@{@"target": self.reactTag});
            break;
        case LFLiveStart:
            self.onStart(@{@"target": self.reactTag});
            break;
        case LFLiveError:
            self.onStreamError(@{@"target": self.reactTag});
            break;
        case LFLiveStop:
            self.onStreamingStopped(@{@"target": self.reactTag});
            break;
        default:
            break;
    }
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
    NSLog(@"Session 호출");
    if (!_session) {
        NSLog(@"Session 생성");
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/


        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/

        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[self getAudioConfiguration] videoConfiguration:[self getVideoConfiguration]];

        /**    自己定制单声道  */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 1;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */

        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(540, 960);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 24;
         videoConfiguration.videoMaxKeyframeInterval = 48;
         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;

         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */

        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.landscape = NO;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;

         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */

        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(1280, 720);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.landscape = YES;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;

         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */

        _session.delegate = self;
        _session.showDebugInfo = YES;
        _session.preView = self;
        //_session.mirror = NO;

        //        UIImageView *imageView = [[UIImageView alloc] init];
        //        imageView.alpha = 0.8;
        //        imageView.frame = CGRectMake(100, 100, 29, 29);
        //        imageView.image = [UIImage imageNamed:@"ios-29x29"];
        //        _session.warterMarkView = imageView;
        //
    }
    return _session;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}


- (void) setStarted:(BOOL) started{
    __weak typeof(self) _self = self;
    if(started != _started){
        if(started){
            LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
            stream.url = _url;
            [_self.session startLive:stream];
        }else{
            [_self.session stopLive];
        }
        _started = started;
    }
}

- (void) setCameraFronted: (BOOL) cameraFronted{
    __weak typeof(self) _self = self;
    if(cameraFronted != _cameraFronted){
        //AVCaptureDevicePosition devicePositon = _self.session.captureDevicePosition;
        if (cameraFronted){
            _self.session.captureDevicePosition = AVCaptureDevicePositionFront;
        }else {
            _self.session.captureDevicePosition = AVCaptureDevicePositionBack;
        }
        _cameraFronted = cameraFronted;
    }
}

- (void) setUrl: (NSString *) url {
    _url = url;
}

- (void) setVideoConfig: (NSDictionary *) videoConfig {
    _videoConfig = videoConfig;
}

- (void) setAudioConfig: (NSDictionary *) audioConfig {
    _audioConfig = audioConfig;
}


- (void) setLandscape: (BOOL) landscape{
    _landscape = landscape;
}


- (LFLiveVideoConfiguration *)getVideoConfiguration {
    LFLiveVideoConfiguration *videoConfig = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Low1 landscape:_landscape];
    if (_videoConfig.count == 0) {
        videoConfig.videoBitRate =  500 * 1024;
        videoConfig.videoMaxBitRate = 500 * 1024;
        videoConfig.videoMinBitRate = 500 * 1024;
        return videoConfig;
    }

    NSUInteger videoBitRate = [RCTConvert NSUInteger:_videoConfig[@"videoBitRate"]];
    if (videoBitRate == 0) {
        videoBitRate = 500 * 1024;
    }
    NSUInteger videoMaxBitRate = [RCTConvert NSUInteger:_videoConfig[@"videoMaxBitRate"]];
    if (videoMaxBitRate == 0) {
        videoMaxBitRate = videoBitRate;
    }
    NSUInteger videoMinBitRate = [RCTConvert NSUInteger:_videoConfig[@"videoMinBitRate"]];
    if (videoMinBitRate == 0) {
        videoMinBitRate = videoBitRate;
    }
    NSUInteger videoFrameRate = [RCTConvert NSUInteger:_videoConfig[@"videoFrameRate"]];
    if (videoFrameRate == 0) {
        videoFrameRate = 15;
    }
    NSUInteger videoMaxFrameRate = [RCTConvert NSUInteger:_videoConfig[@"videoMaxFrameRate"]];
    if (videoMaxFrameRate == 0) {
        videoMaxFrameRate = videoFrameRate;
    }
    NSUInteger videoMinFrameRate = [RCTConvert NSUInteger:_videoConfig[@"videoMinFrameRate"]];
    if (videoMinFrameRate == 0) {
        videoMinFrameRate = videoFrameRate > 15 ? videoFrameRate : 10;
    }
    NSUInteger sessionPreset = [RCTConvert NSUInteger:_videoConfig[@"sessionPreset"]];
    if (sessionPreset == 0) {
        sessionPreset = LFCaptureSessionPreset360x640;
    } else if (sessionPreset > 2) {
        sessionPreset = LFCaptureSessionPreset720x1280;
    }

    videoConfig.videoBitRate =  videoBitRate;
    videoConfig.videoMaxBitRate = videoMaxBitRate;
    videoConfig.videoMinBitRate = videoMinBitRate;
    videoConfig.videoFrameRate = videoFrameRate;
    videoConfig.videoMaxFrameRate = videoMaxFrameRate;
    videoConfig.videoMinFrameRate = videoMinFrameRate;
    videoConfig.sessionPreset = sessionPreset;
    return videoConfig;
}

- (LFLiveAudioConfiguration *)getAudioConfiguration {
    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration defaultConfiguration];
    if (_audioConfig.count == 0) {
        return audioConfig;
    }

    NSUInteger numberOfChannels = [RCTConvert NSUInteger:_audioConfig[@"numberOfChannels"]];
    if (numberOfChannels == 0) {
        numberOfChannels = 2;
    }
    NSUInteger audioSampleRate = [RCTConvert NSUInteger:_audioConfig[@"audioSampleRate"]];
    if (audioSampleRate == 0) {
        audioSampleRate = LFLiveAudioSampleRate_48000Hz;
    }
    NSUInteger audioBitRate = [RCTConvert NSUInteger:_audioConfig[@"audioBitRate"]];
    if (audioBitRate == 0) {
        audioBitRate = LFLiveAudioBitRate_64Kbps;
    }

    audioConfig.numberOfChannels =  numberOfChannels;
    audioConfig.audioSampleRate = audioSampleRate;
    audioConfig.audioBitrate = audioBitRate;
    return audioConfig;
}

@end
