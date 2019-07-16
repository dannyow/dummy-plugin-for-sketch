//
//  DummyPluginController.m
//  DummyPlugin
//
//  Created by Daniel on 16/07/2019.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DummyPluginController.h"

@implementation DummyPluginController

#pragma mark - Singleton
+ (instancetype)sharedController {
    static dispatch_once_t once;
    static id _sharedInstance = nil;
    dispatch_once(&once, ^{
        NSLog(@"About to create the shared controller");
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}


- (void)startPlugin {
    NSLog(@"Starting...");
}
- (void)stopPlugin {
    NSLog(@"Stoping...");
}

- (void)selectionDidChange:(id)context {
    NSLog(@"Changing selection...%@", context);
}

- (NSString*)sendPing:(id)context {
    NSObject *document = [context valueForKey:@"document"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL showMessage = @selector(showMessage:);
    if(document && [document respondsToSelector:showMessage]){
        [document performSelector:showMessage withObject: @"Pong! 🏓"];
    }else{
        NSLog(@"Oooops could not find document in context...");
    }
#pragma clang diagnostic pop

    return @"Pong...";
}

@end
