//
//  AppDelegate.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const OAuth2AuthorizationURL;
extern NSString * const OAuth2TokenURL;
extern NSString * const OAuth2RedirectURI;
extern NSString * const OAuth2AccountType;
extern NSString * const OAuth2SuccessPagePrefix;
extern NSString * const OAuth2ProfileURL;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
