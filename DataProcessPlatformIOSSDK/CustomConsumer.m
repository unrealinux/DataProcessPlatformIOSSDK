#import "CustomConsumer.h"

@implementation CustomConsumer

- (instancetype)initWithChannel:(id<RMQChannel>)channel
                      queueName:(NSString *)queueName
                        options:(RMQBasicConsumeOptions)options        positionProcessor:(PositionProcessor*)posprocessor
        transducerDataProcessor:(TransducerDataProcessor*)transprocessor{
    self = [super initWithChannel:channel queueName:queueName options:options];
    
    if (self) {
        self.positionProcessor = posprocessor;
        self.transProcessor = transprocessor;
    }
    return self;
    
}
@end
