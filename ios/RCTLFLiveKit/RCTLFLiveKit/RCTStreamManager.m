//
//  RCTStreamManager.m
//  RCTLFLiveKit
//
//  Created by 권오빈 on 2016. 8. 9..
//  Copyright © 2016년 권오빈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
#import "RCTStreamManager.h"
//#import "LFLivePreview.h"
#import "RCTStream.h"

@implementation RCTStreamManager

RCT_EXPORT_MODULE();

- (UIView *) view
{
    return [[RCTStream alloc] initWithManager:self bridge:self.bridge];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_VIEW_PROPERTY(started, BOOL);
RCT_EXPORT_VIEW_PROPERTY(cameraFronted, BOOL);
RCT_EXPORT_VIEW_PROPERTY(url, NSString);
RCT_EXPORT_VIEW_PROPERTY(landscape, BOOL);
RCT_EXPORT_VIEW_PROPERTY(audioConfig,NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(videoConfig,NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onReady, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPending, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStart, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStreamError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStreamingStopped, RCTBubblingEventBlock);

@end
