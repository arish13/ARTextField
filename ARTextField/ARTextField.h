//
//  ARTextField.h
//  ARTextFieldExample
//
//  Created by Arian Sharifian on 4/13/14.
//  Copyright (c) 2014 Arish. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ARRequired,
    AREmail,
    ARMatch,
    ARFormat
} ARValidationType;

typedef enum {
    AROnControl = 0,
    ARPopUp
} ARValidationMessageType;

@interface ARTextField : UITextField


- (instancetype)initWithValidationTypes:(NSArray*)validationTypes andValidationMessage:(NSString*)validationMessage withValidationMessageType:(ARValidationMessageType)validationMessageType inFrame:(CGRect)rect;

@property (nonatomic) ARValidationMessageType ValidationMessageType;

@property (strong) NSString* ValidationMessage;

@property (strong) NSArray* ValidationTypes;

@property (strong) UITextField* MatchingControl;

@property (strong) NSString* FormatRegex;

- (BOOL)Validate;
- (void)Invalidate;
- (void)InvalidateWithMessage:(NSString*)message;

@end
