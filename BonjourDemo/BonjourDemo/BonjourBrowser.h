//
//  BonjourBrowser.h
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BonjourBrowserDelegate;

@interface BonjourBrowser : NSObject

@property (nonatomic, weak) id<BonjourBrowserDelegate> delegate;

- (void)search;
- (void)stop;

@end



@protocol BonjourBrowserDelegate <NSObject>

@optional
- (void)bonjourBrowswer:(BonjourBrowser *)browser didUpdateServices:(NSArray *)services;
                         
@end
