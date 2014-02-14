//
//  LinkedinOAuth2.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/14/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

extern NSString * const OAuth2AuthorizationURL;
extern NSString * const OAuth2TokenURL;
extern NSString * const OAuth2RedirectURI;
extern NSString * const OAuth2AccountType;
extern NSString * const OAuth2SuccessPagePrefix;
extern NSString * const OAuth2ProfileURL;

@interface LinkedinOAuth2 : NSObject

- (BOOL)accountInit;
- (void)setupNotifiers;
- (void)handleAuthResponse:(NSString *)authResponse;
- (void)requestProtectedData;
- (BOOL)clearAccounts;

@end
