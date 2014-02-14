//
//  OAuth2LoginView.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkedinOAuth2.h"

@interface OAuth2LoginView : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) LinkedinOAuth2 *linkedinOauth2;
@property (weak, nonatomic) IBOutlet UITextField *addressBar;
@property (weak, nonatomic) IBOutlet UIWebView *loginWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@end
