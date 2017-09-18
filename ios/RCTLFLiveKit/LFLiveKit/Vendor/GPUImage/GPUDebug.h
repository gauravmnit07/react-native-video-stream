//
//  GPUDebug.h
//  LFLiveKit
//
//  Created by Gaurav Bansal on 9/18/17.
//  Copyright © 2017 admin. All rights reserved.
//

#ifndef GPUDebug_h
#define GPUDebug_h

// The general purpose logger. This ignores logging levels.
#ifdef DEBUG
#define GPUDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define GPUDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG


#endif /* GPUDebug_h */
