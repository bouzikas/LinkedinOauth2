//
//  ProfileViewController.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth2LoginView.h"

@protocol OAuth2LoginViewProtocol <NSObject>

- (void)dismissAndLoginView;

@end


@interface ProfileViewController : UIViewController <NSXMLParserDelegate>

- (IBAction)logoutAction:(id)sender;

@property (nonatomic, weak) id <OAuth2LoginViewProtocol> delegate;
@property (nonatomic, retain) OAuth2LoginView *oAuth2LoginView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
