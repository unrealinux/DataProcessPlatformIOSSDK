#import <RMQClient/RMQClient.h>
#import "TransducerDataProcessor.h"

@interface CustomConsumer : RMQConsumer

@property (nonatomic, strong) PositionProcessor* positionProcessor;
@property (nonatomic, strong) TransducerDataProcessor* transProcessor;


- (instancetype)initWithChannel:(id<RMQChannel>)channel
                      queueName:(NSString *)queueName
                        options:(RMQBasicConsumeOptions)options
              positionProcessor:(PositionProcessor*)posprocessor
        transducerDataProcessor:(TransducerDataProcessor*)transprocessor;

@end
