use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{Transaction, ScriptContext, Spend}
use aiken/transaction/credential.{VerificationKey, Address}

type DonorInfo {
  is_us_based: Bool,
}

type BannedWallet {
  address: ByteArray,
}

const irs_wallet: ByteArray = #"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef" // Example IRS address

// Read banned wallets from external file
validator {
  fn check_donor_and_where(
    donor_info: DonorInfo,
    redeemer: Data,
    ctx: ScriptContext,
  ) -> Bool {
    when ctx.purpose is {
      Spend(_) -> {
        let tx: Transaction = ctx.transaction
        let sender_address = tx.inputs[0].address
        
        // Check if wallet is in banned list
        let banned_wallets: List<BannedWallet> = read_banned_wallets()
        let is_banned = list.any(
          banned_wallets,
          fn(banned) { banned.address == sender_address },
        )
        
        if is_banned || donor_info.is_us_based {
          // Transfer to IRS wallet
          verify_transfer_to_irs(tx)
        } else {
          // Return to sender
          verify_return_to_sender(tx, sender_address)
        }
      }
      _ -> False
    }
  }
}

fn verify_transfer_to_irs(tx: Transaction) -> Bool {
  // Verify output is going to IRS wallet
  let outputs = tx.outputs
  list.any(
    outputs,
    fn(output) { output.address == irs_wallet },
  )
}

fn verify_return_to_sender(tx: Transaction, sender: ByteArray) -> Bool {
  // Verify output is returning to sender with original signature
  let outputs = tx.outputs
  list.any(
    outputs,
    fn(output) {
      output.address == sender &&
        verify_signature(output)
    },
  )
}

// Helper function to verify signature
fn verify_signature(output: TransactionOutput) -> Bool {
  when output.address.payment_credential is {
    VerificationKey(vkey) -> True // Add actual signature verification
    _ -> False
  }
}