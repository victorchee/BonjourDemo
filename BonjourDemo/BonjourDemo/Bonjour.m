//
//  Bonjour.m
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "Bonjour.h"

@interface Bonjour() <NSNetServiceDelegate> {
    NSNetService *service;
}

@end

@implementation Bonjour

- (instancetype)init {
    if (self = [super init]) {
        service = [[NSNetService alloc] initWithDomain:@"local." type:@"_test._tcp." name:@"Bonjour" port:0];
        service.delegate = self;
    }
    return self;
}

- (void)publish {
    [service publishWithOptions:NSNetServiceListenForConnections];
}

- (void)stop {
    [service stop];
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"will publish");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"did publish");
    NSData *versionData = [@"1.0" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *textRecord = @{@"version": versionData};
    NSData *txtRecordData = [NSNetService dataFromTXTRecordDictionary:textRecord];
    sender.TXTRecordData = txtRecordData;
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"did not publish: %@", errorDict);
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    
}

- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"did stop");
//    sender.delegate = nil;
//    sender = nil;
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    
}

@end
