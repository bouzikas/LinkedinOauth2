//
//  BViewController.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/19/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth2LoginView.h"

@protocol OAuth2LoginViewProtocol <NSObject>

- (void)dismissAndLoginView;

@end

@interface BViewController : UIViewController

@property (nonatomic, weak) id <OAuth2LoginViewProtocol> delegate;
@property (nonatomic, retain) OAuth2LoginView *linkedinView;


@end
