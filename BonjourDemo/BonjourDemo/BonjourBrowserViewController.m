//
//  BonjourBrowserViewController.m
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "BonjourBrowserViewController.h"
#import "BonjourBrowser.h"

@interface BonjourBrowserViewController () <BonjourBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate> {
    BonjourBrowser *browser;
    NSArray *bonjourServices;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableData *receiveData;
    NSMutableData *sendData;
    NSNumber *bytesRead;
    NSNumber *bytesWritten;
}

@end

@implementation BonjourBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    browser = [[BonjourBrowser alloc] init];
    browser.delegate = self;
    
    sendData = [[@"OK" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [browser search];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [browser stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BonjourBrowserDelegate
- (void)bonjourBrowswer:(BonjourBrowser *)browser didUpdateServices:(NSArray *)services {
    bonjourServices = services;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return bonjourServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSNetService *service = bonjourServices[indexPath.row];
    cell.textLabel.text = service.domain;
    cell.detailTextLabel.text = service.name;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNetService *service = bonjourServices[indexPath.row];
    service.delegate = self;
    [service resolveWithTimeout:5];
    
    [browser stop];
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"Will resolve");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"did not resolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"did resolve");
    
//    NSDictionary *txtDictionary = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
//    NSData *versionData = txtDictionary[@"version"];
//    NSString *version = [[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding];
    
    NSInputStream *tempIS;
    NSOutputStream *tempOS;
    if (![sender getInputStream:&tempIS outputStream:&tempOS]) {
        NSLog(@"Stream failed");
    }
    
    if (tempIS != NULL) {
        inputStream = tempIS;
        inputStream.delegate = self;
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        if (inputStream.streamStatus == NSStreamStatusNotOpen) {
            [inputStream open];
        }
    }
    
    if (tempOS != NULL) {
        outputStream = tempOS;
        outputStream.delegate = self;
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        if (outputStream.streamStatus == NSStreamStatusNotOpen) {
            [outputStream open];
        }
        [outputStream write:sendData.bytes maxLength:sendData.length];
    }
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            if (aStream == outputStream && sendData.length > 0) {
                uint8_t *readBytes = (uint8_t *)sendData.mutableBytes;
                readBytes += bytesWritten.integerValue;
                NSUInteger length = sendData.length - bytesWritten.integerValue;
                length = length >= 1024 ? 1024 : length;
                
                uint8_t buffer[length];
                (void)memcpy(buffer, readBytes, length);
                length = [(NSOutputStream *)aStream write:(const uint8_t *)buffer maxLength:length];
                
                bytesWritten = @(bytesWritten.integerValue + length);
                
                if (sendData.length == bytesWritten.integerValue) {
//                    sendData = nil;
                    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                }
                
                if (bytesWritten.integerValue == -1) {
                    NSLog(@"Error writing data.");
                }
                
                NSLog(@"write data");
            }
        }
            break;
            
        case NSStreamEventHasBytesAvailable:
        {
            if (aStream == inputStream) {
                if (receiveData == nil) {
                    receiveData = [[NSMutableData alloc] init];
                }
                uint8_t buffer[1024];
                NSUInteger length = 0;
                length = [(NSInputStream *)aStream read:buffer maxLength:1024];
                NSLog(@"receive: %@", [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:(const void *)buffer length:length] encoding:NSUTF8StringEncoding]);
                
                if (length) {
                    [receiveData appendBytes:(const void *)buffer length:length];
                    bytesRead = @(bytesRead.integerValue + length);
                    if (![inputStream hasBytesAvailable]) {
                        NSLog(@"receive data: %@", [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding]);
                    } else {
                        NSLog(@"No data found in buffer.");
                    }
                }
                NSLog(@"read data");
            }
        }
            break;
            
        case NSStreamEventOpenCompleted:
            NSLog(@"stream opend");
            break;
            
        case NSStreamEventEndEncountered:
        {
            NSLog(@"End of stream reached.");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            if (aStream == inputStream) {
                NSLog(@"Input stream error: %@", [aStream streamError]);
            } else {
                NSLog(@"Output stream error: %@", [aStream streamError]);
            }
        }
            break;
            
        default:
            break;
    }
}

@end
