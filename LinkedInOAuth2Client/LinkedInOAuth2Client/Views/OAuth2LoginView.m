//
//  OAuth2LoginView.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "OAuth2LoginView.h"
#import "AppDelegate.h"
#import "NXOAuth2.h"


@interface OAuth2LoginView ()

@end

@implementation OAuth2LoginView

#pragma mark - Synthesize properties

@synthesize linkedinOauth2;
@synthesize addressBar;
@synthesize loginWebView;

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.loadIndicator startAnimating];
    self.loadIndicator.hidesWhenStopped = YES;
}

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
    
    // add delegation for the UIWebView
    self.loginWebView.delegate = self;
    
    // Setup account data & initialize notifiers
    linkedinOauth2 = [[LinkedinOAuth2 alloc] init];
    
    if([linkedinOauth2 accountInit]){
        [linkedinOauth2 setupNotifiers];
        
        // Fire authorization code request
        [self requestAuthCode];
    } else {
        [linkedinOauth2 requestProtectedData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate Methods


- (void)requestAuthCode {
    
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:OAuth2AccountType
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
                                       
                                       // navigate to the URL returned by NXOAuth2Client
                                       [self.loginWebView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                   }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadIndicator stopAnimating];
    
    if ([webView.request.URL.absoluteString rangeOfString:OAuth2AuthorizationURL options:NSCaseInsensitiveSearch].location != NSNotFound) {
        // Ignoring
    } else {
        
        // Page title should contain the code provided by Linkedin in the redirect_uri
        NSString *redirectPageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        // Here we have to check if state is valid & procced in request of access_token
        [linkedinOauth2 handleAuthResponse:redirectPageTitle];
    }
}


@end
