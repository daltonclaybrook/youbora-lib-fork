//
//  YBRequest.m
//  YouboraLib
//
//  Created by Joan on 16/03/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YBRequest.h"
#import "YBLog.h"

NSString * const YouboraHTTPMethodGet = @"GET";
NSString * const YouboraHTTPMethodPost = @"POST";
NSString * const YouboraHTTPMethodHead = @"HEAD";
NSString * const YouboraHTTPMethodOptions = @"OPTIONS";
NSString * const YouboraHTTPMethodPut = @"PUT";
NSString * const YouboraHTTPMethodDelete = @"DELETE";
NSString * const YouboraHTTPMethodTrace = @"TRACE";

@interface YBRequest()

/// ---------------------------------
/// @name Private properties
/// ---------------------------------

@property(nonatomic, strong) NSMutableArray<YBRequestSuccessBlock> * successListenerList;
@property(nonatomic, strong) NSMutableArray<YBRequestErrorBlock> * errorListenerList;
@property(nonatomic, assign) unsigned int pendingAttempts;

@end

@implementation YBRequest

static NSMutableArray<YBRequestSuccessBlock> * everySuccessListenerList;
static NSMutableArray<YBRequestErrorBlock> * everyErrorListenerList;

#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.successListenerList = [NSMutableArray arrayWithCapacity:1];
        self.errorListenerList = [NSMutableArray arrayWithCapacity:1];
        
        self.maxRetries = 3;
        self.retryInterval = 5000;
        self.method = YouboraHTTPMethodGet;
    }
    return self;
}

- (instancetype) initWithHost:(nullable NSString *) host andService:(nullable NSString *) service {
    self = [self init];
    self.host = host;
    self.service = service;
    return self;
}

#pragma mark - Public methods
-(void)send {
    self.pendingAttempts = self.maxRetries + 1;
    [self sendRequest];
}

-(NSURL *)getUrl {
    //NSURLComponents * components = [NSURLComponents new];
    NSURLComponents * components = [NSURLComponents componentsWithString:self.host];
    //components.host = self.host;
    components.path = self.service;
    
    // Build query params
    if (self.params != nil && self.params.count > 0) {
        
        NSMutableArray<NSURLQueryItem *> * queryItems = [NSMutableArray arrayWithCapacity:self.params.count];
        
        for (NSString * key in self.params) {
            NSString * value = self.params[key];
            if (value != nil) {
                // Avoid sending null values
                NSURLQueryItem * queryItem = [NSURLQueryItem queryItemWithName:key value:value];
                [queryItems addObject:queryItem];
            }
        }
        
        [components setQueryItems:queryItems];
    }
    
    return components.URL;
}

- (void)setParam:(NSString *)value forKey:(NSString *)key {
    if (self.params == nil) {
        self.params = [NSMutableDictionary dictionaryWithObject:value forKey:key];
    } else {
        [self.params setObject:value forKey:key];
    }
}

- (NSString *)getParam:(NSString *)key {
    return [self.params objectForKey:key];
}

#pragma mark - Private methods
- (NSMutableURLRequest *) createRequestWithUrl:(NSURL *) url {
    return [NSMutableURLRequest requestWithURL:url];
}

- (void) sendRequest {
    self.pendingAttempts--;
    @try {
        // Create request object
        NSMutableURLRequest * request = [self createRequestWithUrl:[self getUrl]];
        
        if ([YBLog isAtLeastLevel:YBLogLevelVerbose]) {
            [YBLog requestLog:[NSString stringWithFormat:@"XHR Req: %@", request.URL.absoluteString]];
        }
        
        // Set request headers if any
        if (self.requestHeaders != nil && self.requestHeaders.count > 0) {
            [request setAllHTTPHeaderFields:self.requestHeaders];
        }
        
        request.HTTPMethod = self.method;
                
        // Send request
        __weak typeof(self) weakSelf = self;
        NSURLSession * session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = self;
            if (strongSelf == nil) {
                [YBLog error:@"YBRequest instance has been deallocated while waiting for completion handler"];
                return;
            }
            
            if (error == nil) {
                [weakSelf didSucceedWithData:data andResponse:response];
            } else {
                [weakSelf didFailWithError:error];
            }
        }] resume];
        
    } @catch (NSException *exception) {
        [YBLog logException:exception];
        [self didFailWithError:nil];
    }
}

- (void) didSucceedWithData:(NSData *) data andResponse:(NSURLResponse *) response {
    for (YBRequestSuccessBlock block in everySuccessListenerList) {
        @try {
            block(data, response);
        } @catch (NSException *exception) {
            [YBLog logException:exception];
        }
    }
    
    for (YBRequestSuccessBlock block in self.successListenerList) {
        @try {
            block(data, response);
        } @catch (NSException *exception) {
            [YBLog logException:exception];
        }
    }
}

- (void) didFailWithError:(NSError *) error {
    
    // Callbacks
    for (YBRequestErrorBlock block in everyErrorListenerList) {
        @try {
            block(error);
        } @catch (NSException *exception) {
            [YBLog logException:exception];
        }
    }
    
    for (YBRequestErrorBlock block in self.errorListenerList) {
        @try {
            block(error);
        } @catch (NSException *exception) {
            [YBLog logException:exception];
        }
    }
    
    // Retry
    if (self.pendingAttempts > 0) {
        [YBLog warn:[NSString stringWithFormat:@"Request \"%@\" failed. Retry %d of %d in %dms.", self.service, (self.maxRetries + 1 - self.pendingAttempts), self.maxRetries, self.retryInterval]];
        __weak typeof (self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof (weakSelf) strongSelf = weakSelf;
            [strongSelf sendRequest];
        });
    } else {
        [YBLog error:[NSString stringWithFormat:@"Aborting failed request \"%@\". Max retries reached(%d)", self.service, self.maxRetries]];
    }
}

#pragma mark - Static methods
- (void) addRequestSuccessListener:(YBRequestSuccessBlock) successBlock{
    if (successBlock != nil && ![self.successListenerList containsObject:successBlock]) {
        [self.successListenerList addObject:successBlock];
    }
}
- (void) removeRequestSuccessListener:(YBRequestSuccessBlock) successBlock{
    if (successBlock != nil) {
        [self.successListenerList removeObject:successBlock];
    }
}
- (void) addRequestErrorListener:(YBRequestErrorBlock) errorBlock{
    if (errorBlock != nil && ![self.errorListenerList containsObject:errorBlock]) {
        [self.errorListenerList addObject:errorBlock];
    }
}
- (void) removeRequestErrorListener:(YBRequestErrorBlock) errorBlock{
    if (errorBlock != nil) {
        [self.errorListenerList removeObject:errorBlock];
    }
}
+ (void) addEveryRequestSuccessListener:(YBRequestSuccessBlock) successBlock{
    if (successBlock != nil) {
        if (everySuccessListenerList == nil) {
            everySuccessListenerList = [NSMutableArray arrayWithObject:successBlock];
        } else {
            [everySuccessListenerList addObject:successBlock];
        }
    }
}
+ (void) removeEveryRequestSuccessListener:(YBRequestSuccessBlock) successBlock{
    if (everySuccessListenerList != nil && successBlock != nil) {
        [everySuccessListenerList removeObject:successBlock];
    }
}
+ (void) addEveryRequestErrorListener:(YBRequestErrorBlock) errorBlock{
    if (errorBlock != nil) {
        if (everyErrorListenerList == nil) {
            everyErrorListenerList = [NSMutableArray arrayWithObject:errorBlock];
        } else {
            [everyErrorListenerList addObject:errorBlock];
        }
    }
}
+ (void) removeEveryRequestErrorListener:(YBRequestErrorBlock) errorBlock{
    if (everyErrorListenerList != nil && errorBlock != nil) {
        [everyErrorListenerList removeObject:errorBlock];
    }
}
@end