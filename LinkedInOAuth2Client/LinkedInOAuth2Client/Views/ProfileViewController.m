//
//  ProfileViewController.m
//  LinkedInOAuth2Client
//
//  Created by Dimitris Bouzikas on 2/11/14.
//  Copyright (c) 2014 Designed. All rights reserved.
//

#import "ProfileViewController.h"
#import "LinkedinOAuth2.h"
#import "AppDelegate.h"
#import "BViewController.h"
#import "XMLParser.h"

@interface ProfileViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ProfileViewController

@synthesize profilePhoto;
@synthesize fullname;
@synthesize location;
@synthesize jobPosition;

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if(![(AppDelegate*)[[UIApplication sharedApplication] delegate] authenticated]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        BViewController *initView =  (BViewController*)[storyboard instantiateViewControllerWithIdentifier:@"initialView"];
        [initView setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:initView animated:NO completion:nil];
    } else{
    
        LinkedinOAuth2 *oauth2 = [[LinkedinOAuth2 alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileDataRetrieved:)
                                                     name:@"profileDataRetrieved"
                                                   object:oauth2];
        [oauth2 requestProtectedData];
    }
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Load Profile photo"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}

-(void) profileDataRetrieved:(NSNotification*)notification {
    
    self.queue = [[NSOperationQueue alloc] init];
    
    NSData *xmlProfile = [[notification userInfo] objectForKey:@"response"];
    
    XMLParser *parser = [[XMLParser alloc] initWithData:xmlProfile];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    __weak XMLParser *weakParser = parser;
    
    parser.completionBlock = ^(void) {
        if (weakParser.workingEntry != nil) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.userProfile = weakParser.workingEntry;
                [self loadData];
            });
        }
        
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
    
    [self.queue addOperation:parser];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData{
    NSMutableString *fullName = [[NSMutableString alloc] initWithString:self.userProfile.name];
    [fullName appendFormat:@" %@",self.userProfile.surname];
    
    fullname.text = fullName;
    jobPosition.text = self.userProfile.jobPosition;
    location.text = self.userProfile.location;
    
    [self downloadImage:[NSURL URLWithString:self.userProfile.imageURLString]];
}

- (IBAction)logout:(id)sender {
    LinkedinOAuth2 *oauth2 = [[LinkedinOAuth2 alloc] init];
    [oauth2 clearAccounts];
    
    AppDelegate *authObj = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    authObj.authenticated = [oauth2 userAuthenticated];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    BViewController *initView =  (BViewController*)[storyboard instantiateViewControllerWithIdentifier:@"initialView"];
    [initView setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:initView animated:YES completion:nil];
}

#pragma mark - Profile image request

- (void)downloadImage:(NSURL *)url {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error ) {
                                   self.profilePhoto.image = [[UIImage alloc] initWithData:data];
                               } else {
                                   NSLog(@"%@", error);
                               }
                           }];
}

@end
