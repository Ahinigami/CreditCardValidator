//
//  RMYCardValidator.m
//  fintech
//
//  Created by Cheah Bee Kim on 05/08/2017.
//  Copyright © 2017 test. All rights reserved.
//

#import "RMYCardValidator.h"
#import "RMYCreditCardSpec.h"

NSString * const RMYCreditCardType_toString[] = {
    [RMYCreditCardTypeAmex] = @"AMEX",
    [RMYCreditCardTypeVisa] = @"VISA",
    [RMYCreditCardTypeMastercard] = @"MASTER_CARD",
    [RMYCreditCardTypeDiscover] = @"DISCOVER",
    [RMYCreditCardTypeDinersClub] = @"DINERS_CLUB",
    [RMYCreditCardTypeJCB] = @"JCB",
    [RMYCreditCardTypeUnionPay] = @"UNION_PAY",
    [RMYCreditCardTypeHiper] = @"HIPER",
    [RMYCreditCardTypeElo] = @"ELO",
    [RMYCreditCardTypeUnsupported] = @"UNSUPPORTED",
    [RMYCreditCardTypeInvalid] = @"INVALID"
};

@interface RMYCardValidator ()

//Credit card specs
@property (nonatomic, strong) NSDictionary *creditCardSpecs;
@property (nonatomic, strong) NSArray<NSNumber *> *allowedCreditCardTypes;

//
@property (nonatomic) NSInteger minAllowedCharLength;
@property (nonatomic) NSInteger systemMonth;
@property (nonatomic) NSInteger systemYear;

@property (nonatomic) BOOL checkLuhn;

@end

@implementation RMYCardValidator

+ (void)initialize
{
    [super initialize];
}

+ (instancetype)sharedInstance
{
    static RMYCardValidator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [RMYCardValidator new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    NSDictionary *creditCardSpecs = [RMYCardValidator loadLocalCreditCardSpecs];
    
    NSArray *allowedCreditCardTypes = @[@(RMYCreditCardTypeAmex),
                                        @(RMYCreditCardTypeVisa),
                                        @(RMYCreditCardTypeMastercard),
                                        @(RMYCreditCardTypeDiscover),
                                        @(RMYCreditCardTypeDinersClub),
                                        @(RMYCreditCardTypeJCB),
                                        @(RMYCreditCardTypeUnionPay),
                                        @(RMYCreditCardTypeHiper),
                                        @(RMYCreditCardTypeElo)];
    
    self = [self initWithCreditCardSpecs:creditCardSpecs
                  allowedCreditCardTypes:allowedCreditCardTypes];
    
    if (self) {
        self.minAllowedCharLength = 9;
        
    }
    
    return self;
}

- (instancetype)initWithCreditCardSpecs:(NSDictionary *)creditCardSpecs
                 allowedCreditCardTypes:(NSArray<NSNumber *> *)allowedCreditCardTypes
{
    self = [super init];
    
    if (self) {
        _creditCardSpecs = creditCardSpecs;
        _allowedCreditCardTypes = allowedCreditCardTypes;
        
    }
    
    return self;
}

#pragma mark - Methods
- (RMYCreditCardType)typeFromString:(NSString *)string
{
    return [self typeFromString:string
                         strict:YES];
}

- (RMYCreditCardType)typeFromString:(NSString *)string
                             strict:(BOOL)strict
{
    __block RMYCreditCardType type = RMYCreditCardTypeInvalid;
    
    /*
     If strict is enabled, check the string length against the minimum allowed
     char length.
     Bear in mind, even if the credit card spec does not specify the char
     lengths, turning on strict checking will still require that the
     card length cannot be less specified value
     */
    if (strict) {
        if (string.length < _minAllowedCharLength) {
            return RMYCreditCardTypeInvalid;
        }
    }
    
    [_creditCardSpecs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        RMYCreditCardType _type = [key integerValue];
        NSPredicate *predicate = [self predicateForType:_type
                                                 strict:strict];
        BOOL isCurrentType = [predicate evaluateWithObject:string];
        if (isCurrentType) {
            type = _type;
            *stop = YES;
        }
        
    }];
    
    if (type != RMYCreditCardTypeInvalid && strict) {
        RMYCreditCardSpec *spec = [_creditCardSpecs objectForKey:@(type)];
        
        /*
         If no spec was found, return RMYCreditCardTypeInvalid.
         */
        if (!spec) {
            return RMYCreditCardTypeInvalid;
        }
        
        BOOL valid = ([RMYCardValidator validateLuhn:string] &&
                      [RMYCardValidator validateCharLengths:string
                                                       spec:spec]);
        
        /*
         If string does not pass the Luhn test or char lengths from
         the spec, return RMYCreditCardTypeInvalid
         */
        if (!valid) {
            return RMYCreditCardTypeInvalid;
        }
    }
    
    return type;
}

- (NSPredicate *)predicateForType:(RMYCreditCardType)type
{
    return [self predicateForType:type
                           strict:YES];
}

- (NSPredicate *)predicateForType:(RMYCreditCardType)type
                           strict:(BOOL)strict
{
    if (type == RMYCreditCardTypeInvalid || type == RMYCreditCardTypeUnsupported) {
        return nil;
    }
    
    NSString *regex;
    RMYCreditCardSpec *spec = [_creditCardSpecs objectForKey:@(type)];
    regex = strict ? spec.patternStrict : spec.pattern;
    
    if (!regex) {
        return nil;
    }
    
    return [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
}

- (BOOL)validateString:(NSString *)string
     forCreditCardType:(RMYCreditCardType)creditCardType
{
    return [self typeFromString:string] == creditCardType;
}

- (BOOL)validateString:(NSString *)string
{
    NSString *formattedString = [RMYCardValidator formattedStringForProcessing:string];
    if (!formattedString) {
        return NO;
    }
    
    RMYCreditCardType type = [self typeFromString:formattedString
                                           strict:YES];
    
    BOOL flagTypeIsValid = (type != RMYCreditCardTypeInvalid &&
                            type != RMYCreditCardTypeUnsupported);
    BOOL flagTypeIsAllowed = [_allowedCreditCardTypes indexOfObject:@(type)] != NSNotFound;
    
    return flagTypeIsValid && flagTypeIsAllowed;
}

#pragma mark -
+ (NSDictionary *)loadLocalCreditCardSpecs
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"credit_card_specs"
                                      ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:kNilOptions
                                                          error:nil];
    
    NSMutableDictionary *responseSpec = [NSMutableDictionary new];
    
    for (NSString *key in dic) {
        NSDictionary *dicCreditCardSpec = [dic objectForKey:key];
        RMYCreditCardType type = [RMYCardValidator RMYCreditCardTypeForString:key];
        
        if (dicCreditCardSpec && type != NSNotFound) {
            RMYCreditCardSpec *spec = [[RMYCreditCardSpec alloc] init];
            
            spec.pattern = [dicCreditCardSpec objectForKey:@"pattern"];
            spec.patternStrict = [dicCreditCardSpec objectForKey:@"patternStrict"];
            spec.charLengths = [dicCreditCardSpec objectForKey:@"charLengths"];
            spec.charGrouping = [dicCreditCardSpec objectForKey:@"charGrouping"];
            spec.cvcLength = [[dicCreditCardSpec objectForKey:@"cvcLength"] integerValue];
            
            [responseSpec setObject:spec
                             forKey:@(type)];
        } else {
            // Log know error
            if (type == NSNotFound) {
                NSLog(@"%s: No RMYCreditCardSpec enum found for key: (%@).\nPlease check if the key value is correct, else add the newly added key into the enum for the newly added spec",
                      __PRETTY_FUNCTION__,
                      key);
            }
        }
    }
    
    return responseSpec;
}

+ (RMYCreditCardType)RMYCreditCardTypeForString:(NSString *)string
{
    RMYCreditCardType type = NSNotFound;
    
    for (NSInteger i = 0; i < sizeof(RMYCreditCardType_toString); i++) {
        if ([RMYCreditCardType_toString[i] isEqualToString:string]) {
            type = i;
            
            break;
        }
    }
    
    return type;
}


+ (NSString *)formattedStringForProcessing:(NSString *)string
{
    NSCharacterSet *illegalCharacters = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:illegalCharacters];
    
    return [components componentsJoinedByString:@""];
}

+ (BOOL)validateCharLengths:(NSString *)string
                       spec:(RMYCreditCardSpec *)spec
{
    BOOL flag = NO;
    
    /*
     If no charLengths configuration was found, set the flag condition
     to true without performing additional checking.
     Else, check the value length with the specified charLengths combination
     */
    if (!spec.charLengths || spec.charLengths.count == 0) {
        flag = YES;
    } else {
        for (NSNumber *tRange in spec.charLengths) {
            NSInteger integerRange = [tRange integerValue];
            
            if (integerRange == string.length) {
                flag = YES;
                
                break;
            }
        }
    }
    
    return flag;
}

+ (BOOL)validateLuhn:(NSString *)string
{
    BOOL flag = NO;
    
    NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:string.length];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                            usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                [reversedString appendString:substring];
                            }];
    
    NSUInteger oddSum = 0, evenSum = 0, sum = 0;
    
    for (NSUInteger i = 0; i < reversedString.length; i++) {
        unichar c = [reversedString characterAtIndex:i];
        NSInteger digit = [[NSString stringWithFormat:@"%C", c] integerValue];
        
        //If c is not numeric, return NO
        if (![numericSet characterIsMember:c]) {
            return NO;
        }
        
        if (i % 2 == 0) {
            evenSum += digit;
        } else {
            oddSum += digit / 5 + (2 * digit) % 10;
        }
    }
    
    sum = oddSum + evenSum;
    
    if (sum != 0 && sum % 10 == 0) {
        flag = YES;
    }
    
    return flag;
}

@end
