//
//  Tests.m
//  Tests
//
//  Created by Cheah Bee Kim on 19/09/2017.
//  Copyright © 2017 test. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "RMYCardValidator.h"
#import "RMYCreditCardSpec.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLuhn {
    NSArray *arrValid = @[@"4111111111111111",
                          @"4988438843884305",
                          @"4166676667666746",
                          @"4646464646464644",
                          @"4444333322221111",
                          @"4400000000000008",
                          @"4977949494949497"];
    NSArray *arrInvalid = @[@"",
                            @"a",
                            @"  1",
                            @"4977 9494 9494 9497",
                            @"49",
                            @"4111111111111110",
                            @"4988438843884300",
                            @"4166676667666740",
                            @"4646464646464640",
                            @"4444333322221110",
                            @"4400000000000000",
                            @"4977949494949490",];
    
    for (NSString *string in arrValid) {
        XCTAssertTrue([RMYCardValidator validateLuhn:string], @"");
    }
    
    for (NSString *string in arrInvalid) {
        XCTAssertFalse([RMYCardValidator validateLuhn:string],
                       @"Credit card number %@ should failed the luhn test", string);
    }
}

- (void)testVisa {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSArray *arrValid = @[@"4111111111111111",
                          @"4988438843884305",
                          @"4166676667666746",
                          @"4646464646464644",
                          @"4444333322221111",
                          @"4400000000000008",
                          @"4977949494949497"];
    
    NSArray *arrSimple = @[@"4",
                           @"47"];
    
    for (NSString *str in arrValid) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:YES];
        
        XCTAssertTrue(valid, @"");
        XCTAssertEqual(type, RMYCreditCardTypeVisa, @"");
    }
    
    for (NSString *str in arrSimple) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:NO];
        
        XCTAssertFalse(valid);
        XCTAssertEqual(type, RMYCreditCardTypeVisa, @"");
    }
}

- (void)testAmex {
    NSArray *arrValid = @[@"374251018720018",
                          @"374251021090003",
                          @"374101012180018",
                          @"374251033270007"];
    NSArray *arrSimple = @[@"37",
                           @"34"];
    
    for (NSString *str in arrValid) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:YES];
        
        XCTAssertTrue(valid, @"");
        XCTAssertEqual(type, RMYCreditCardTypeAmex, @"");
    }
    
    for (NSString *str in arrSimple) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:NO];
        
        XCTAssertFalse(valid);
        XCTAssertEqual(type, RMYCreditCardTypeAmex, @"");
    }
}

- (void)testMastercard {
    NSArray *arrValid = @[@"5100081112223332",
                          @"5100290029002909",
                          @"5577000055770004",
                          @"5136333333333335",
                          @"5585558555855583",
                          @"5555444433331111",
                          @"5555555555554444",
                          @"5500000000000004",
                          @"5424000000000015"];
    NSArray *arrSimple = @[@"51",
                           @"55",
                           @"54"];
    
    for (NSString *str in arrValid) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:YES];
        
        XCTAssertTrue(valid, @"");
        XCTAssertEqual(type, RMYCreditCardTypeMastercard, @"");
    }
    
    for (NSString *str in arrSimple) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:NO];
        
        XCTAssertFalse(valid);
        XCTAssertEqual(type, RMYCreditCardTypeMastercard, @"");
    }
}

- (void)testJCB {
    NSArray *arrValid = @[@"3569990010095841"];
    NSArray *arrSimple = @[@"35",
                           @"3512",
                           @"2131",
                           @"1800"];
    
    for (NSString *str in arrValid) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:YES];
        
        XCTAssertTrue(valid, @"");
        XCTAssertEqual(type, RMYCreditCardTypeJCB, @"");
    }
    
    for (NSString *str in arrSimple) {
        BOOL valid = [[RMYCardValidator sharedInstance] validateString:str];
        RMYCreditCardType type = [[RMYCardValidator sharedInstance] typeFromString:str
                                                                            strict:NO];
        
        XCTAssertFalse(valid);
        XCTAssertEqual(type, RMYCreditCardTypeJCB, @"");
    }
}

- (void)testCreditCardDate
{
    NSDate *date = [NSDate new];
    
    NSDateFormatter *simpleDateFormatter = [NSDateFormatter new];
    simpleDateFormatter.dateFormat = @"MM / yy";
    
    NSDateFormatter *fullDateFormatter = [NSDateFormatter new];
    fullDateFormatter.dateFormat = @"MM / yyyy";
    
    NSLog(@"%s: SimpleDate: (%@)",
          __PRETTY_FUNCTION__,
          [simpleDateFormatter stringFromDate:date]);
    
    NSLog(@"%s: fullDate: (%@)",
          __PRETTY_FUNCTION__,
          [fullDateFormatter stringFromDate:date]);
    
}

@end
