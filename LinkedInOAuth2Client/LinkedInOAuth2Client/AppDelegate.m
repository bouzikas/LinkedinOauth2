//
//  AppDelegate.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "AppDelegate.h"
#import "NXOAuth2.h"

#define STATE_LENGTH 16

@implementation AppDelegate

// LinkedIn API documentation
// http://developer.linkedin.com/documents/authentication

static NSString * const OAuth2ClientID = @"API_KEY";
static NSString * const OAuth2SecretKey = @"SECRET_KEY";

NSString * const OAuth2AuthorizationURL = @"https://www.linkedin.com/uas/oauth2/authorization";
NSString * const OAuth2TokenURL = @"https://www.linkedin.com/uas/oauth2/accessToken";
NSString * const OAuth2RedirectURI = @"REDIRECT_URI";
NSString * const OAuth2AccountType = @"LinkedIn";

// Set your desirable response prefix
NSString * const OAuth2SuccessPagePrefix = @"code=";
NSString * const OAuth2ProfileURL = @"https://api.linkedin.com/v1/people/~?";

static NSSet *OAuth2Scopes;

+ (void)initialize;
{
    if (self == [AppDelegate class]) {
        OAuth2Scopes = [[NSSet alloc] initWithObjects:@"r_basicprofile", @"rw_nus", nil];
    }
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: STATE_LENGTH];
    
    for (int i = 0; i < STATE_LENGTH; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    NSMutableString *OAuth2AuthorizationURLWithState = [[NSMutableString alloc] initWithString:OAuth2AuthorizationURL];
    [OAuth2AuthorizationURLWithState appendFormat:@"?state=%@", randomString];
    
    [[NXOAuth2AccountStore sharedStore] setClientID:OAuth2ClientID
                                             secret:OAuth2SecretKey
                                              scope:OAuth2Scopes
                                   authorizationURL:[NSURL URLWithString:OAuth2AuthorizationURLWithState]
                                           tokenURL:[NSURL URLWithString:OAuth2TokenURL]
                                        redirectURL:[NSURL URLWithString:OAuth2RedirectURI]
                                     forAccountType:OAuth2AccountType];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
