SURFnet OS X SSO Library
===================================================

Now you can easily integrate the [SURFnet](https://www.surf.nl) SSO process flow in your OS X application by using this library.

If you want to see it in action, check out the demo app in this repository.


HOW TO USE THE LIBRARY
-----

Before you can use the library you need to have your `consumerId` registered by SURFnet and have received your `consumer secret`.

### Include library

If you are using CocoaPods, add the following line to your Podfile:

    pod 'SSOService-OSX'

alternatively, add the code from the SSOService folder into your project directly.

### Register URL scheme

In the Info.plist of your app, add an entry in CFBundleURLTypes with the value for CFBundleURLSchemes set to the one registered with Surfnet.

### Showing authorization screen

When you want to let the user login, create an authorization view controller and display it.

    - (IBAction)authorize:(id)sender {
        [SSOService authorizeForEndpoint:@"https://nonweb.demo.surfconext.nl/php-oauth-as/authorize.php" consumerId:@"your consumer id" state:@"demo" delegate:self];
    }

You should also implement a few delegate callback methods.

    #pragma mark - SSOAuthorizationDelegate

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

### Receiving access token

The access token will be delivered to your app via a callback URL. In your application delegate, implement these methods to handle the URL.

    - (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    }

    - (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
        NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
        if (urlString == nil) {
            return;
        }
        NSURL *url = [NSURL URLWithString:urlString];
        if (url == nil) {
            return;
        }
        BOOL urlHandled = [SSOService handleURL:url callbackScheme:@"sfoauth"];
        if (!urlHandled) {
            // Handle any other URLs
        }
    }



[CHANGELOG](https://github.com/SURFnet/nonweb-sso-osx/blob/master/CHANGELOG.md)
-----

Current version: 0.0.1


DEVELOPED BY
------------

* SURFnet - [https://www.surf.nl](https://www.surf.nl)
* Egeniq - [https://www.egeniq.com/](https://www.egeniq.com/)


LICENSE
-----

    Copyright 2015 SURFnet BV, The Netherlands

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.