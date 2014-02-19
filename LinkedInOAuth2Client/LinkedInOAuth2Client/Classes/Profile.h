//
//  Profile.h
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/19/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *jobPosition;

@end
