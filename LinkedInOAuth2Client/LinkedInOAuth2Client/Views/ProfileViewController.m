//
//  ProfileViewController.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "NXOAuth2.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize oAuth2LoginView;


#pragma mark - View Lifecycle

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action & Retrieve Methods

- (IBAction)loginBtnPressed:(id)sender {
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:oAuth2LoginView];
    
    [self performSegueWithIdentifier:@"openLinkedinSegue" sender:sender];
}

#pragma mark - Dismissing Delegate Methods

static BOOL loggedIn = NO;

- (void)dismissAndLoginView {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (!loggedIn)
        return;
    
    // Change button's text
    [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    
    // Remove existing login via linkedin action
    [self.loginButton removeTarget:nil action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add logout action
    [self.loginButton addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)logoutAction:(id)sender{
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    }
    
    // Change button's text
    [self.loginButton setTitle:@"Login using LinkedIn" forState:UIControlStateNormal];
    
    // Remove existing logout action
    [self.loginButton removeTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add login via linkedin action
    [self.loginButton addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Clear profile labels
    self.nameLabel.text = @"Name: ";
    self.surnameLabel.text = @"Surname: ";
    self.jobLabel.text = @"Job: ";
}

-(void) loginViewDidFinish:(NSNotification*)notification {
    NSData *xmlProfile = [[notification userInfo] objectForKey:@"response"];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlProfile];
    [parser setDelegate:self];
    [parser parse];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissAndLoginView];
}

#pragma mark - XML Parsing

static NSString *tagName = nil;
static NSString * const firstName;
static NSString * const lastName;
static NSString * const jobPosition;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"error"]){
        return;
    }
    
    loggedIn = YES;
    tagName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"Ending of Element: [%@]", elementName);
    if([elementName isEqualToString:@"person"]){
        NSLog(@"Ending of Root Element");
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if([tagName isEqualToString:@"first-name"]) {
        self.nameLabel.text = [self.nameLabel.text stringByAppendingString:string];
    } else if([tagName isEqualToString:@"last-name"]) {
        self.surnameLabel.text = [self.surnameLabel.text stringByAppendingString:string];
    } else if([tagName isEqualToString:@"headline"]) {
        self.jobLabel.text = [self.jobLabel.text stringByAppendingString:string];
    }
    
    tagName = nil;
}

@end
