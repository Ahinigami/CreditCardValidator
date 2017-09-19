//
//  RMYCreditCardSpec.h
//  fintech
//
//  Created by Cheah Bee Kim on 05/08/2017.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMYCreditCardSpec : NSObject

/*
 pattern and patternStrict is the regex used to validate the
 credit card number.
 pattern is used loosely to validate credit card without 
 the full format validation.
 E.g.; When user typed 4, it will be able to determined the card
 is a Visa card.
 */
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, copy) NSString *patternStrict;

/*
 charRange is used to specify the possible combinations of
 length of the credit card, e.g.; @[@(16), @(19)] would mean
 that the possible valid length of the credit card can only
 be either 16 or 19.
 If charRange is null, skip the checking for credit card length
 */
@property (nonatomic, copy) NSArray<NSNumber *> *charLengths;

/* 
 Char grouping is used for specifying the grouping of credit card
 number. e.g.; @[@(4), @(4), @(4), @(4)] would results in
 grouping the numbers in 4 digits such as 1111 1111 1111 1111
 */
@property (nonatomic, copy) NSArray<NSNumber *> *charGrouping;

@property (nonatomic) NSInteger cvcLength;

@end
