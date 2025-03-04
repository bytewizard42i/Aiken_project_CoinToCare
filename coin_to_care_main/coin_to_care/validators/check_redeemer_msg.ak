// *** Validator: Check Redeemer Message ***

use aiken/transaction.{Transaction, ScriptContext, Spend}
use lib/datum_custom_types.{My_datum}
use lib/redeemer_custom_types.{My_redeemer}

// Validator function to check redeemer message
validator {
  fn check_user_redeemer_input(datum: My_datum, redeemer: My_redeemer, ctx: ScriptContext) -> Bool {
    when ctx.purpose is {
      Spend(_) -> {
        // Check if the redeemer message is "See my redeemer input selection"
        redeemer.msg == #"536565206d792072656465656d657220696e7075742073656c656374696f6e" // Hex for "See my redeemer input selection"
      }
      _ -> False
    }
  }
}