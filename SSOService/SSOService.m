/*
 * Copyright 2015 SURFnet BV, The Netherlands
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SSOService.h"

NSString * const _Nonnull SSOServiceErrorDomain = @"SSOServiceErrorDomain";

@interface SSOService ()

+ (nonnull instancetype)sharedInstance;

@property (nonatomic, weak) id <SSOAuthorizationDelegate> delegate;

@end

@implementation SSOService

+ (nonnull instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (nonnull NSURL *)URLForEndpoint:(NSString * _Nonnull)endpoint consumerId:(NSString * _Nonnull)consumerId state:(NSString * _Nonnull)state {
    NSURLComponents *components = [NSURLComponents componentsWithString:endpoint];
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"client_id" value:consumerId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"response_type" value:@"token"]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"state" value:state]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"scope" value:@"authorize"]];
    components.queryItems = queryItems;
    return components.URL;
}

+ (BOOL)authorizeForEndpoint:(NSString * _Nonnull)endpoint consumerId:(NSString * _Nonnull)consumerId state:(NSString * _Nonnull)state delegate:(id <SSOAuthorizationDelegate> _Nonnull)delegate {
    id <SSOAuthorizationDelegate> previousDelegate = [SSOService sharedInstance].delegate;
    if (previousDelegate != nil) {
        NSError *error = [NSError errorWithDomain:SSOServiceErrorDomain code:SSOServiceErrorAuthorizationCancelled userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The authorization was cancelled.", @"Message shown when a second authorization is requested")}];
        [previousDelegate authorizationDidFailWithError:error];
    }

    [SSOService sharedInstance].delegate = delegate;

    NSURL *authorizationURL = [self URLForEndpoint:endpoint consumerId:consumerId state:state];
    return [[NSWorkspace sharedWorkspace] openURL:authorizationURL];
}


+ (BOOL)handleURL:(NSURL * _Nonnull)url callbackScheme:(NSString * _Nonnull)callbackScheme {
    // Replace the weird hashtag with the correct question mark
    NSString *urlString  = [[url absoluteString] stringByReplacingOccurrencesOfString:@"#access_token=" withString:@"?access_token="];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    id <SSOAuthorizationDelegate> delegate = [SSOService sharedInstance].delegate;
    if ([components.scheme isEqualToString:callbackScheme]) {
        NSString *token = nil;
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if ([queryItem.name isEqualToString:@"access_token"]) {
                token = queryItem.value;
                break;
            }
        }
        if (token) {
            [delegate authorizationDidSucceedWithToken:token];
        } else {
            NSError *error = [NSError errorWithDomain:SSOServiceErrorDomain code:SSOServiceErrorAuthorizationCancelled userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The authorization was cancelled.", @"Message shown when callback url has no access token")}];
            [delegate authorizationDidFailWithError:error];
        }
        [SSOService sharedInstance].delegate = nil;
        return YES;
    }
    return NO;
}

@end
