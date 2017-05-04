#import <Foundation/Foundation.h>
#import "TransportCommData.h"

@interface TransducerDataProcessor : NSObject

- (void) newTransducerData:(TransportCommData*) data;

- (void) newData:(NSString *)data;

@end
