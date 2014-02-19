//
//  BViewController.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/19/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "BViewController.h"
#import "AppDelegate.h"

@interface BViewController ()

@end

@implementation BViewController{
    BOOL hasLogout;
}

@synthesize linkedinView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //hasLogout = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileDataRetrieved:)
                                                 name:@"profileDataRetrieved"
                                               object:linkedinView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnPressed:(id)sender {
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:linkedinView];
}

#pragma mark - Dismissing Delegate Methods

- (void)dismissLoginAndShowProfile {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabView = [storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [self presentViewController:tabView animated:YES completion:nil];
}

-(void) loginViewDidFinish:(NSNotification*)notification {
    [self dismissViewControllerAnimated:NO completion:^{
        LinkedinOAuth2 *linkedinOauth2 = [[LinkedinOAuth2 alloc] init];
        [linkedinOauth2 requestProtectedData];
    }];
}

-(void) profileDataRetrieved:(NSNotification*)notification {
    
    AppDelegate *authObj = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    authObj.authenticated = YES;
    
    [self dismissLoginAndShowProfile];
}

@end
