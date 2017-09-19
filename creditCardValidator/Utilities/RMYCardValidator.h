//
//  RMYCardValidator.h
//  fintech
//
//  Created by Cheah Bee Kim on 05/08/2017.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMYCreditCardSpec;

typedef NS_ENUM(NSInteger, RMYCreditCardType) {
    RMYCreditCardTypeAmex,
    RMYCreditCardTypeVisa,
    RMYCreditCardTypeMastercard,
    RMYCreditCardTypeDiscover,
    RMYCreditCardTypeDinersClub,
    RMYCreditCardTypeJCB,
    RMYCreditCardTypeUnionPay,
    RMYCreditCardTypeHiper,
    RMYCreditCardTypeElo,
    RMYCreditCardTypeUnsupported,   // Reserved for future purpose, use case would probably be allowing unsupported card that pass all the basic validation checking such as Luhn test and character length test. This would probably be used in conjuction with strict = NO.
    RMYCreditCardTypeInvalid
};

extern NSString * const RMYCreditCardType_toString[];

@interface RMYCardValidator : NSObject

// Singleton accessor
+ (instancetype)sharedInstance;

// Common properties
@property (nonatomic, strong, readonly) NSDictionary *creditCardSpecs;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *allowedCreditCardTypes;

/*
 Custom initializer
 */

/**
 Initialize with custom credit card specs and allowed credit card types.
 The provided custom values are not mutable to ensure the behaviour 
 stays the same throughout the execution of each instance.
 
 @param creditCardSpecs         Custom credit cards specs
 @param allowedCreditCardTypes  Custom allowed credit card types
 **/
- (instancetype)initWithCreditCardSpecs:(NSDictionary *)creditCardSpecs
                 allowedCreditCardTypes:(NSArray<NSNumber *> *)allowedCreditCardTypes;

/*
 Generic instance methods
 */

/**
 Get the NSPredicate value for the specific credit card type
 
 @param type    The type of credit card which the predicate will be returned.
 **/
- (NSPredicate *)predicateForType:(RMYCreditCardType)type;

/**
 Get the NSPredicate value for the specific credit card type
 
 @param type    The type of credit card which the predicate will be returned.
 @param strict  Used to obtain the strict pattern for validation. Strict
                pattern should use slightly longer time and processing
                power but is useful for times when absolute validation
                is required. By default, strict is set to YES.
 **/
- (NSPredicate *)predicateForType:(RMYCreditCardType)type
                           strict:(BOOL)strict;

/**
 Resolve the string to RMYCreditCardType by checking it against the
 instance credit card specs.
 
 @param string  The target string to be resolved
 @param strict  Used to perform the checking using the strict pattern.
                Setting it NO is useful to check the credit card type
                ambigously without having user to type in the full
                credit card value. By default, strict is set to YES.
 **/
- (RMYCreditCardType)typeFromString:(NSString *)string
                             strict:(BOOL)strict;

/**
 Resolve the string to RMYCreditCardType by checking it against the
 instance credit card specs.
 
 @param string  The target string to be resolved
 **/
- (RMYCreditCardType)typeFromString:(NSString *)string;

/**
 Check if the credit card value is valid
 
 @param string          The value of the credit card to be validated
 @param creditCardType  The credit card spec to use for the validation
 **/
- (BOOL)validateString:(NSString *)string
     forCreditCardType:(RMYCreditCardType)creditCardType;

- (BOOL)validateString:(NSString *)string;

/* 
 Generic static methods
 */

/**
 Validate the credit card using Luhn algorithm. 
 For more info: https://en.wikipedia.org/wiki/Luhn_algorithm
 
 @param string  The value of the credit card to be validated
 **/
+ (BOOL)validateLuhn:(NSString *)string;

/**
 Validate the credit card characters length using the spec provided
 
 @param string  The value of the credit card to be validated
 @param spec    The spec to be use for the validation
 **/
+ (BOOL)validateCharLengths:(NSString *)string
                       spec:(RMYCreditCardSpec *)spec;

/**
 Return the RMYCreditCardType for the provided string value
 
 @return    RMYCreditCardType or NSNotFound.
            NSNotFound is returned in the event the string value 
            that matches RMYCreditCardType could not be found.
 **/
+ (RMYCreditCardType)RMYCreditCardTypeForString:(NSString *)string;

@end
