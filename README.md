# CreditCardValidator
A simple tools to validate credit card using predefined credit card specs in credit_card_specs.json.

e.g.
```json
{
  "AMEX": {
    "pattern": "^3[47]([0-9\\s]?)+",
    "patternStrict": "^3[47][0-9]{5,}$",
    "charLengths": [15],
    "charGrouping": [4, 6, 5],
    "cvcLength": "4"
  },
  "VISA": {
    "pattern": "^4([0-9\\s]?)+",
    "patternStrict": "^4[0-9]{6,}$",
    "charLengths": [13, 16, 19],
    "charGrouping": [4],
    "cvcLength": "3"
  }
}
```

Strict mode includes checking for exact characters defined in the credit card specs and validate the card numbers using Luhn algorithm.

Without the strict flag, the checking will be done loosely to support identifying the credit card without user typing in the full card number.

To test the functionality, simply press ⌘ + b to build the test cases in creditCardValidatorTests using predefined valid and invalid credit cards.

# TODO
1) Bundle the code as a standalone framework.
2) UI to showcase the credit card validator using.
3) Errors to be return using NSError with custom domain name and error code.
4) Cocoapods.
5) Swift version.
