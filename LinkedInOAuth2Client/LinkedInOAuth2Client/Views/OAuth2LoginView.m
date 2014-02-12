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

@synthesize addressBar;
@synthesize loginWebView;

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.loadIndicator startAnimating];
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
    
    self.loadIndicator.hidesWhenStopped = YES;
    
    // add delegation for the UIWebView
    self.loginWebView.delegate = self;
    
    [self setupNotifiers];
    [self requestAuthCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate Methods

- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      
                                                      if (aNotification.userInfo) {
                                                          
                                                          //access token added, so we can now make requests in protected data
                                                          NSLog(@"Access token received!");
                                                          [self requestProtectedData];
                                                          
                                                      } else {
                                                          if ([[[NXOAuth2AccountStore sharedStore] accounts] count] > 0){
                                                              for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
                                                                  [[NXOAuth2AccountStore sharedStore] removeAccount:account];
                                                              }
                                                          }
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
        [self handleAuthResponse:redirectPageTitle];
    }
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
    NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:OAuth2AccountType];
    
    NSString *mytoken = [[accounts[0] accessToken] accessToken];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:mytoken, @"oauth2_access_token", nil];
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:OAuth2ProfileURL]
                   usingParameters:parameters
                       withAccount:nil
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   // e.g., update a progress indicator
               }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       
                       // If is response, return it at Profile View Controller
                       if (responseData) {
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"loginViewDidFinish" object:self userInfo:@{@"response": responseData}];
                           [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                           
                       }
                       if (error) {
                           NSLog(@"%@", error.description);
                       }
                   }];
}


@end
