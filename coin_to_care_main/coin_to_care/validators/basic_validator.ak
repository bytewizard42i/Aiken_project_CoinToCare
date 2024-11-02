// *** This file contains the validator function that checks if the redeemer message is "Hello, Aiken!" ***

use aiken/crypto.{VerificationKeyHash}
use aiken/primitive/string
use cardano/transaction.{Transaction}

//                                  Import necessary types from Cardano libraries

// Defined the custom Datum type, containing the owner's public key hash. Code is located in the datum_custom_types.ak file

// Define the Redeemer type, containing a message. Code is located in the redeemer_custom_types.ak file

// Validator function that checks if the redeemer message is "Hello, Aiken!"
validator simple_check {
  spend(datum: Option<Datum>, redeemer: Redeemer, _o: Data, tx: Transaction) {
    // Ensure datum is provided and matches expected structure
    expect Some(Datum { owner }) = datum

    // Check that the redeemer message matches "Hello, Aiken!"
    let valid_message = redeemer.msg == "Hello, Aiken!"

    // Return true if the message matches
    valid_message
  }

  else(_) {
    fail
  }
}
