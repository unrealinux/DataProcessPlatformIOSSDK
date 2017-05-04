//
//  DataProcessPlatformComm.m
//  DataProcessPlatformIOSSDK
//
//  Created by xielinus on 2017/5/4.
//  Copyright © 2017年 circletechcircletech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataProcessPlatformComm.h"
//@import RMQClient;
#import <RMQClient/RMQClient.h>
#import "CustomConsumer.h"

static id<RMQChannel> ch;
static NSString* amqpconfig;
static RMQQueue* q;
static NSString* queuename;

@implementation GPSComm

+ (bool) init:(NSString *)configpath{
    
    NSLog(@"Attempting to connect to local RabbitMQ broker");
    
    NSDictionary* data = [[NSDictionary alloc] initWithContentsOfFile:configpath];
    amqpconfig = [data objectForKey:@"Amqp config"];
    
    RMQConnection *conn = [[RMQConnection alloc] initWithUri:amqpconfig delegate:[RMQConnectionDelegateLogger new]];
    
    [conn start];
    
    ch = [conn createChannel];
    [ch exchangeDeclare:@"gps-rabbitmq" type:@"topic" options:RMQExchangeDeclareDurable];
    
    q = [ch queue:@""];
    return true;
}

+ (bool) open:(NSString*) message andPosition:(PositionProcessor *)positionProcessor andTransducer:(TransducerDataProcessor *)transducerDataProcessor{
    
    if ([message isEqualToString:@"ios-open-pos"]) {
        [ch queueBind:q.name exchange:@"gps-rabbitmq" routingKey:@"ios-gps-pos-data"];
    }else if ([message isEqualToString:@"ios-open-sensor"]){
        [ch queueBind:q.name exchange:@"gps-rabbitmq" routingKey:@"ios-gps-sensor-data"];
    }
    
    [ch.defaultExchange publish:[message dataUsingEncoding:NSUTF8StringEncoding] routingKey:@"gps-data"];
    NSLog(@"Sent 'open'");
    
    NSLog(@"Waiting for messages.");
    CustomConsumer *consumer = [[CustomConsumer alloc] initWithChannel:ch queueName:q.name options:RMQBasicConsumeNoOptions
                                                     positionProcessor:positionProcessor transducerDataProcessor:transducerDataProcessor];
    
    [consumer onDelivery:^(RMQMessage * _Nonnull message) {
        NSString* jsonMessage = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
        
        if ([message.routingKey isEqualToString:@"ios-gps-pos-data"]) {
            if (consumer.positionProcessor != NULL) {
                [consumer.positionProcessor newData:jsonMessage];
            }
        } else {
            if (consumer.transProcessor != NULL) {
                [consumer.transProcessor newData:jsonMessage];
            }
        }
        
        
        NSLog(@"Received:%@:%@", message.routingKey, [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
    }];
    
    [ch basicConsume:consumer];
    
    /*
     [q subscribe:^(RMQMessage * _Nonnull message) {
     NSString* jsonMessage = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
     
     if ([message.routingKey isEqualToString:@"ios-gps-pos-data"]) {
     if (positionProcessor != NULL) {
     [positionProcessor newData:jsonMessage];
     }
     } else {
     if (transducerDataProcessor != NULL) {
     [transducerDataProcessor newData:jsonMessage];
     }
     }
     
     
     NSLog(@"Received:%@:%@", message.routingKey, [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
     }];
     */
    
    return true;
}

+ (bool) close:(NSString*) message{
    
    [ch.defaultExchange publish:[message dataUsingEncoding:NSUTF8StringEncoding] routingKey:@"gps-data"];
    
    if ([message isEqualToString:@"ios-close-pos"]) {
        [ch queueUnbind:q.name exchange:@"gps-rabbitmq" routingKey:@"ios-gps-pos-data"];
    }else if ([message isEqualToString:@"ios-close-sensor"]){
        [ch queueUnbind:q.name exchange:@"gps-rabbitmq" routingKey:@"ios-gps-sensor-data"];
    }
    return true;
}

@end

