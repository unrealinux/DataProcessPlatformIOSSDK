//
//  DataProcessPlatformComm.h
//  DataProcessPlatformIOSSDK
//
//  Created by xielinus on 2017/5/4.
//  Copyright © 2017年 circletechcircletech. All rights reserved.
//

#ifndef DataProcessPlatformComm_h
#define DataProcessPlatformComm_h

#import <Foundation/Foundation.h>
#import "TransducerDataProcessor.h"

@interface DataProcessPlatformComm : NSObject

+ (bool) init:(NSString*) configpath;

+ (bool) open:(NSString*) message andPosition:(TransducerDataProcessor*) transducerDataProcessor;

+ (bool) close:(NSString*) message;

@end


#endif /* DataProcessPlatformComm_h */
