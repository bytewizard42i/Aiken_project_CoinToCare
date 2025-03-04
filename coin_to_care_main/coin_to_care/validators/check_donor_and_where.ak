// *** Validator: Check Donor and Location ***

use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{Transaction, ScriptContext, Spend}
use aiken/transaction/credential.{Address, VerificationKey}
use aiken/builtin
use lib/banned_wallets_list.{BannedWallet, banned_wallets}
use lib/datum_custom_types.{My_datum}

// Custom type for donor information
type DonorInfo {
  is_us_based: Bool,
}

// IRS wallet address (replace with actual ByteArray)
const irs_wallet: ByteArray = #"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"

// Validator function
validator {
  fn check_donor_and_where(datum: My_datum, redeemer: Data, ctx: ScriptContext) -> Bool {
    when ctx.purpose is {
      Spend(_) -> {
        let tx: Transaction = ctx.transaction
        // Get sender's address from the first input
        let sender_address: Address = tx.inputs[0].address
        // Extract the hash from the address
        let sender_hash: ByteArray = extract_address_hash(sender_address)
        
        // Check if sender is banned
        let banned_wallets: List<BannedWallet> = banned_wallets()
        let is_banned = list.any(banned_wallets, fn(bw) { bw.address == sender_hash })
        
        // Placeholder for donor location (to be replaced with DIDz geo-location later)
        let donor_info = DonorInfo { is_us_based: True } // Temporary; adjust as needed
        
        // Decision logic
        if is_banned || donor_info.is_us_based {
          verify_transfer_to_irs(tx)
        } else {
          verify_return_to_sender(tx, sender_address)
        }
      }
      _ -> False
    }
  }
}

// Helper to extract hash from address
fn extract_address_hash(address: Address) -> ByteArray {
  when address.payment_credential is {
    VerificationKey(vkh) -> vkh
    ScriptCredential(sh) -> sh
  }
}

// Placeholder for IRS transfer verification
fn verify_transfer_to_irs(tx: Transaction) -> Bool {
  list.any(tx.outputs, fn(output) { output.address.payment_credential == irs_wallet })
}

// Placeholder for return to sender verification
fn verify_return_to_sender(tx: Transaction, sender: Address) -> Bool {
  list.any(tx.outputs, fn(output) { output.address == sender })
}