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

#import "ViewController.h"

#import "SSOService.h"

@interface ViewController () <SSOAuthorizationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (IBAction)authorize:(id)sender {
    [SSOService authorizeForEndpoint:@"https://nonweb.demo.surfconext.nl/php-oauth-as/authorize.php" consumerId:@"4dca00da67c692296690e90c50c96b79" state:@"demo" delegate:self];
}

- (void)authorizationDidSucceedWithToken:(NSString * _Nonnull)token {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Authorization succeeded", @"");
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"Access token: %@", @""), token];
    [alert runModal];
}

- (void)authorizationDidFailWithError:(NSError * _Nonnull)error {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

@end
