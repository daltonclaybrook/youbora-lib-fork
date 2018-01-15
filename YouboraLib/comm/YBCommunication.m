//
//  YBCommunication.m
//  YouboraLib
//
//  Created by Joan on 20/03/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YBCommunication.h"
#import "YBLog.h"
#import "YBRequest.h"
#import "YBTransform.h"

@interface YBCommunication()

@property (nonatomic, strong) NSMutableArray<YBTransform *> * transforms;

@property (nonatomic, strong) NSMutableArray<YBRequest *> * requests;

@end

@implementation YBCommunication

#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transforms = [NSMutableArray array];
        self.requests = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public methods
- (void)sendRequest:(YBRequest *)request withCallback:(nullable YBRequestSuccessBlock)callback {
    if (request != nil) {
        if (callback != nil) {
            [request addRequestSuccessListener:callback];
        }
        [self registerRequest:request];
    }
}

- (void)addTransform:(YBTransform *)transform {
    if (transform != nil) {
        [transform addTransformDoneListener:self];
        [self.transforms addObject:transform];
    } else {
        [YBLog warn:@"Transform is nil in addTransform"];
    }
}

- (void)removeTransform:(nullable YBTransform *)transform {
    if (transform != nil) {
        [self.transforms removeObject:transform];
    }
}

#pragma mark - Private methods
- (void) registerRequest:(YBRequest *) request {
    [self.requests addObject:request];
    [self processRequests];
}

- (void) processRequests {
    for (int i = (int) self.requests.count - 1; i >= 0; i--) {
        YBRequest * request = self.requests[i];
        if ([self transform:request]) {
            [self.requests removeObjectAtIndex:i];
            [request send];
        }
    }
}

- (bool) transform: (YBRequest *) request {
    for (YBTransform * transform in self.transforms) {
        if ([transform isBlocking:request]) {
            return false;
        } else {
            [transform parse:request];
        }
    }
    
    return true;
}

#pragma mark - YBTransformDoneListener delegate
- (void)transformDone:(YBTransform *)transform {
    [self processRequests];
}


@end
