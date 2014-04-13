//
//  ARViewController.h
//  ARTextFieldExample
//
//  Created by Arian Sharifian on 4/13/14.
//  Copyright (c) 2014 Arish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARTextField.h"

@interface ARViewController : UIViewController

@property (strong, nonatomic) IBOutlet ARTextField *Email;
@property (strong, nonatomic) IBOutlet ARTextField *Password;
@property (strong, nonatomic) IBOutlet ARTextField *Confirm;

@end
