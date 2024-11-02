// *** This file contains the validator function that verifies if the user input redeemer message is "See my redeemer input selection" ***

use aiken/crypto.{VerificationKeyHash}
use aiken/primitive/string
use cardano/transaction.{Transaction}
use datum_custom_types.my_datum
use redeemer_custom_types.my_redeemer
//                                  Import necessary types from Cardano libraries


// Defined the custom Datum type, containing the owner's public key hash. Code is located in the datum_custom_types.ak file

// Define the custom Redeemer type, containing a message. Code is located in the redeemer_custom_types.ak file

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
//								 Validator function that checks if the redeemer message is "See my redeemer input selection" 
