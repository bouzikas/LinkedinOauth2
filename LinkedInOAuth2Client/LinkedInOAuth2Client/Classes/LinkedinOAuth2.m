//
//  LinkedinOAuth2.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/14/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "LinkedinOAuth2.h"

@implementation LinkedinOAuth2

#pragma mark - Initialize variables

#define STATE_LENGTH 16

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
NSString * const OAuth2ProfileURL = @"https://api.linkedin.com/v1/people/~";

static NSSet *OAuth2Scopes;
static NSString * const defaultFields = @"first-name,last-name,headline";
static NSMutableArray *ProfileFields = nil;

#pragma mark - Constructor

- (BOOL)accountInit;
{
    if(ProfileFields == nil) ProfileFields = [NSMutableArray arrayWithObjects:@"first-name", @"last-name", @"email-address", @"headline",@"picture-url", nil];
    
    if ([[[NXOAuth2AccountStore sharedStore] accounts] count] > 0){
        return NO;
    }
    
    OAuth2Scopes = [[NSSet alloc] initWithObjects:@"r_basicprofile", @"r_emailaddress", nil];
    
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
    return YES;
}

- (void)setupNotifiers{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      
                                                      if (aNotification.userInfo) {
                                                          
                                                          //access token added, so we can now make requests in protected data
                                                          NSLog(@"Access token received!");
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"loginViewDidFinish" object:self userInfo:nil];
                                                          
                                                      } else {
                                                          [self clearAccounts];
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      NSLog(@"Error occured %@", error.localizedDescription);
                                                      
                                                  }];
}

- (void)handleAuthResponse:(NSString *)authResponse
{
    // Check if accessResult contain the OAuth2SuccessPagePrefix
    if ([authResponse rangeOfString:OAuth2SuccessPagePrefix options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        // Extract auth code through title
        NSString *authCode = authResponse;
        if ([authCode hasPrefix:OAuth2SuccessPagePrefix]) {
            authCode = [authCode substringFromIndex:OAuth2SuccessPagePrefix.length];
        }
        
        // Append auth_code argument found in the page title into the OAuth2RedirectURI
        NSString *redirectURL = [NSString stringWithFormat:@"%@?code=%@", OAuth2RedirectURI, authCode];
        
        // Complete OAuth2 flow to retrieve access_token by calling handleRedirectURL
        [[NXOAuth2AccountStore sharedStore] handleRedirectURL:[NSURL URLWithString:redirectURL]];
        
    } else {
        // response its not what we expect
    }
}

- (void)requestProtectedData {
    NSMutableString *finOAuth2ProfileURL = [[NSMutableString alloc] initWithString:[OAuth2ProfileURL stringByAppendingString:[self addProfileFields:ProfileFields]]];
    
    NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:OAuth2AccountType];
    
    NSString *mytoken = [[accounts[0] accessToken] accessToken];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:mytoken, @"oauth2_access_token", nil];
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:finOAuth2ProfileURL]
                   usingParameters:parameters
                       withAccount:nil
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   // e.g., update a progress indicator
               }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       
                       // If is response, return it at Profile View Controller
                       if (responseData) {
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"profileDataRetrieved" object:self userInfo:@{@"response": responseData}];
                           
                       }
                       if (error) {
                           NSLog(@"%@", error.description);
                       }
                   }];
}

- (NSString *)addProfileFields:(NSArray *)profileFields{
    
    NSMutableString *fields = [[NSMutableString alloc]init];
    
    if([profileFields count] > 0){
        for(int i = 0; i < [profileFields count]; i++ ){
            [fields appendFormat:@"%@,", profileFields[i]];
        }
    } else{
        [fields appendFormat:@"%@,", defaultFields];
    }
    
    return [[NSMutableString alloc] initWithFormat:@":(%@)?", [fields substringToIndex:[fields length] - 1]];
}

- (BOOL)clearAccounts{
    
    BOOL cleared = NO;
    if ([[[NXOAuth2AccountStore sharedStore] accounts] count] > 0){
        for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
            [[NXOAuth2AccountStore sharedStore] removeAccount:account];
            cleared = YES;
        }
    }
    
    return cleared;
}

@end
