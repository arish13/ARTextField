//
//  ARTextField.m
//  ARTextFieldExample
//
//  Created by Arian Sharifian on 4/13/14.
//  Copyright (c) 2014 Arish. All rights reserved.
//

#import "ARTextField.h"
#import "UIImage+ImageEffects.h"
#import "FBShimmeringView.h"

@interface ARTextField () <UITextFieldDelegate> {
    id<UITextFieldDelegate> OldDelegate;
    UIColor* OldColor;
    UIColor* OldTextColor;
    
    UIImageView* waitImage;
}

@end

@implementation ARTextField

- (id)initWithValidationTypes:(NSArray *)validationTypes andValidationMessage:(NSString *)validationMessage withValidationMessageType:(ARValidationMessageType)validationMessageType inFrame:(CGRect)rect
{
    if (self = [super initWithFrame:rect]) {
        _ValidationTypes = validationTypes;
        _ValidationMessage = validationMessage;
        _ValidationMessageType = validationMessageType;
    }
    
    return self;
}

- (BOOL)Validate
{
    for (NSNumber* type in self.ValidationTypes) {
        switch (type.intValue) {
            case ARRequired:
                if (!self.text.length) {
                    if (!self.ValidationMessage.length) {
                        [self setValidationMessage:NSLocalizedString(@"this field is required", nil)];
                    }
                    [self Failed];
                    return NO;
                }
                break;
            case AREmail:
                return [self ValidateWithRegex:@"^([0-9a-zA-Z]([-\\.\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,9})$"];
                break;
            case ARFormat:
                return [self ValidateWithRegex:self.FormatRegex];
                break;
            case ARMatch: {
                BOOL matching = [self.text isEqualToString:self.MatchingControl.text];
                if (!matching) {
                    if (!self.ValidationMessage.length) {
                        [self setValidationMessage:NSLocalizedString(@"this field is not matching", nil)];
                    }
                    [self Failed];
                }
                return matching;
                break;
            }
        }
    }
    
    return YES;
}

- (BOOL)ValidateWithRegex:(NSString*)regexFormat
{
    if (!self.ValidationMessage.length) {
        [self setValidationMessage:NSLocalizedString(@"this field does not match the required format", nil)];
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexFormat options:0 error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
    if (!matches) {
        [self Failed];
        return NO;
    }
    
    return matches;
}

- (void)Invalidate
{
    [self Failed];
}

- (void)InvalidateWithMessage:(NSString*)message
{
    [self setValidationMessage:message];
    [self Failed];
}

- (void)Failed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!OldDelegate) {
            OldDelegate = self.delegate;
        }
        [self setDelegate:self];
        
        if (!OldTextColor) {
            OldTextColor = self.textColor;
        }
        [self setTextColor:[UIColor colorWithRed:0.65f green:0 blue:0 alpha:1]];
        
        if (!OldColor) {
            OldColor = [self backgroundColor];
        }
        [self setBackgroundColor:[UIColor colorWithRed:0.7411f green:0.411f blue:0.333f alpha:1]];
        
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.02];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self center].x - 10.0f, [self center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self center].x + 10.0f, [self center].y)]];
        [[self layer] addAnimation:animation forKey:@"position"];
        
        [self becomeFirstResponder];
        [self ShowError];
    });
}

- (void)ShowError
{
    if (self.ValidationMessageType == AROnControl) {
        NSDictionary* attribute = @{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:14],
                                    NSForegroundColorAttributeName: [UIColor redColor]};
        CGRect labelRect = self.bounds;
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, labelRect.size.width - 10, labelRect.size.height - 10)];
        loadingLabel.attributedText = [[NSAttributedString alloc] initWithString:self.ValidationMessage attributes:attribute];
        
        UIImage* blurredImage = [self BlurredSnapshotInRect:labelRect];
        
        if (waitImage) {
            [waitImage removeFromSuperview];
        }
        
        waitImage = [[UIImageView alloc] initWithImage:blurredImage];
        [waitImage setFrame:labelRect];
        
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(5, 5, labelRect.size.width - 10, labelRect.size.height - 10)];
        shimmeringView.contentView = loadingLabel;
        [waitImage addSubview:shimmeringView];
        
        [waitImage addSubview:shimmeringView];
        waitImage.layer.masksToBounds = YES;
        waitImage.layer.cornerRadius = 5;
        // Start shimmering.
        shimmeringView.shimmering = YES;
        
        [waitImage setAlpha:0];
        [self addSubview:waitImage];
        
        [UIView animateWithDuration:0.2 animations:^{
            [waitImage setAlpha:1];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.7 animations:^{
                    [waitImage setAlpha:0];
                } completion:^(BOOL finished) {
                    [waitImage removeFromSuperview];
                    waitImage = nil;
                }];
            });
        }];
    } else {
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
        paragrapStyle.alignment = NSTextAlignmentCenter;
        //    paragrapStyle.firstLineHeadIndent = 2;
        //    paragrapStyle.headIndent = 5;
        //    paragrapStyle.tailIndent = 5;
        NSDictionary* attribute = @{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:14],
                                    NSForegroundColorAttributeName: [UIColor redColor],
                                    NSParagraphStyleAttributeName: paragrapStyle};
        CGRect labelRect = [self.ValidationMessage boundingRectWithSize:CGSizeMake(window.bounds.size.width - 10, window.bounds.size.height - 10)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:attribute
                                                                context:nil];
        labelRect.origin.x += 5;
        labelRect.origin.y += 5;
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:labelRect];
        loadingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        loadingLabel.numberOfLines = 0;
        loadingLabel.attributedText = [[NSAttributedString alloc] initWithString:self.ValidationMessage attributes:attribute];
        
        CGFloat x = ((window.bounds.size.width - labelRect.size.width) /2);
        CGRect rect = CGRectMake(x, 45, labelRect.size.width + 10 , labelRect.size.height + 10);
        
        UIImage* blurredImage = [self BlurredSnapshotInRect:rect];
        
        if (waitImage) {
            [waitImage removeFromSuperview];
        }
        
        waitImage = [[UIImageView alloc] initWithImage:blurredImage];
        [waitImage setFrame:rect];
        
        labelRect.origin.x -= 2;
        labelRect.origin.y -= 2;
        labelRect.size.width += 4;
        labelRect.size.height += 4;
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:labelRect];
        shimmeringView.contentView = loadingLabel;
        [waitImage addSubview:shimmeringView];
        
        [waitImage addSubview:shimmeringView];
        waitImage.layer.masksToBounds = YES;
        waitImage.layer.cornerRadius = 0;
        // Start shimmering.
        shimmeringView.shimmering = YES;
        
        UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = @-10;
        xAxis.maximumRelativeValue = @10;
        
        UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = @-10;
        yAxis.maximumRelativeValue = @10;
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[xAxis, yAxis];
        
        [waitImage addMotionEffect:group];
        
        [waitImage setAlpha:0];
        [window addSubview:waitImage];
        
        [UIView animateWithDuration:0.2 animations:^{
            [waitImage setAlpha:1];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.7 animations:^{
                    [waitImage setAlpha:0];
                } completion:^(BOOL finished) {
                    [waitImage removeFromSuperview];
                    waitImage = nil;
                }];
            });
        }];
    }
    
}

- (UIImage *)BlurredSnapshotInRect:(CGRect)rect
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect buttonRectInBGViewCoords = [window convertRect:rect toView:window];
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    // There he is! The new API method
    [window drawViewHierarchyInRect:CGRectMake(-buttonRectInBGViewCoords.origin.x, -buttonRectInBGViewCoords.origin.y, CGRectGetWidth(window.frame), CGRectGetHeight(window.frame)) afterScreenUpdates:YES];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    snapshotImage = [snapshotImage applyBlurWithRadius:1 tintColor:[UIColor colorWithWhite:0.6 alpha:0.95] saturationDeltaFactor:1.0 maskImage:nil];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (waitImage) {
        [waitImage removeFromSuperview];
        waitImage = nil;
    }
    
    [self setBackgroundColor:OldColor];
    [self setTextColor:OldTextColor];
    [self setDelegate:OldDelegate];
    
    return YES;
}

@end
