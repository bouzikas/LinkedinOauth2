//
//  ProfileViewController.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) Profile *userProfile;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *fullname;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *jobPosition;

@end
