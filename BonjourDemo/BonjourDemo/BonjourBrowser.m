//
//  BonjourBrowser.m
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "BonjourBrowser.h"

@interface BonjourBrowser() <NSNetServiceBrowserDelegate> {
    NSNetServiceBrowser *serviceBrowser;
    NSMutableArray *services;
}

@end

@implementation BonjourBrowser

- (instancetype)init {
    if (self = [super init]) {
        serviceBrowser = [[NSNetServiceBrowser alloc] init];
        serviceBrowser.delegate = self;
        
        services = [NSMutableArray array];
    }
    return self;
}

- (void)search {
    [serviceBrowser searchForServicesOfType:@"_test._tcp." inDomain:@"local."];
}

- (void)stop {
    [serviceBrowser stop];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
    NSLog(@"will search");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    if (![services containsObject:service]) {
        [services addObject:service];
    }
    
    if (!moreComing) {
        // Update UI
        if ([self.delegate respondsToSelector:@selector(bonjourBrowswer:didUpdateServices:)]) {
            [self.delegate bonjourBrowswer:self didUpdateServices:services];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [services removeObject:service];
    
    if (!moreComing) {
        // Update UI
        if ([self.delegate respondsToSelector:@selector(bonjourBrowswer:didUpdateServices:)]) {
            [self.delegate bonjourBrowswer:self didUpdateServices:services];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"%@", errorDict);
    [browser stop];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
//    browser.delegate = nil;
//    browser = nil;
    
    // Update UI
}

@end
