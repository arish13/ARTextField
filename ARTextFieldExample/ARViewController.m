//
//  ARViewController.m
//  ARTextFieldExample
//
//  Created by Arian Sharifian on 4/13/14.
//  Copyright (c) 2014 Arish. All rights reserved.
//

#import "ARViewController.h"

@interface ARViewController ()

- (IBAction)Validate:(id)sender;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Setup Validation Controls
    [self.Email setValidationTypes:@[@(ARRequired), @(AREmail)]];
    [self.Email setValidationMessage:@"A valid email is required"];
    
    [self.Password setValidationTypes:@[@(ARRequired), @(ARFormat)]];
    [self.Password setFormatRegex:@"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{4,10}$"];
    [self.Password setValidationMessage:@"Please provide a password"];
    [self.Password setValidationMessageType:ARPopUp];
    
    [self.Confirm setValidationTypes:@[@(ARMatch)]];
    [self.Confirm setMatchingControl:self.Password];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Validate:(id)sender {
    if (self.Email.Validate) {
        if (self.Password.Validate) {
            if ([self.Confirm Validate]) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Good! you provided well!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
        }
    }
}

@end
