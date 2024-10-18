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

// I had Claudious add this fake-example address for the IRS wallet
const irs_wallet: ByteArray = #"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef" // Example IRS address

// Read banned wallets from external file
validator {
  fn check_donor_and_where(donor_info: DonorInfo, redeemer: Data, ctx: ScriptContext) -> Bool {
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

// Tests:

use aiken/test.{test, expect, should}
use aiken/transaction.{Transaction, ScriptContext}

test complete_donation_flow() {
  // Setup initial state
  let initial_balance = 1000000
  let fee = 2000
  let donor_info = DonorInfo { is_us_based: False }
  
  // Test successful donation flow
  test_step("1. Initialize donation") {
    let tx = setup_donation_tx(initial_balance)
    let ctx = mock_context(tx)
    
    check_donor_and_where(donor_info, (), ctx) |> should.be_ok()
  }
  
  test_step("2. Verify balance after fees") {
    let expected_return = initial_balance - fee
    let tx = setup_return_tx(expected_return)
    let ctx = mock_context(tx)
    
    verify_return_amount(ctx, expected_return) |> should.be_ok()
  }
}

test complete_us_based_flow() {
  // Setup initial state
  let initial_balance = 1000000
  let donor_info = DonorInfo { is_us_based: True }
  
  test_step("1. Initialize US-based donation") {
    let tx = setup_donation_tx(initial_balance)
    let ctx = mock_context(tx)
    
    check_donor_and_where(donor_info, (), ctx) |> should.be_ok()
  }
  
  test_step("2. Verify IRS transfer") {
    let tx = setup_irs_transfer_tx(initial_balance)
    let ctx = mock_context(tx)
    
    verify_irs_transfer(ctx) |> should.be_ok()
  }
}

// Helper functions for integration tests
fn setup_donation_tx(amount: Int) -> Transaction {
  // Create transaction with proper inputs/outputs for donation
}

fn setup_return_tx(amount: Int) -> Transaction {
  // Create transaction for return to sender
}

fn setup_irs_transfer_tx(amount: Int) -> Transaction {
  // Create transaction for IRS transfer
}

fn verify_return_amount(ctx: ScriptContext, expected: Int) -> Bool {
  // Verify the returned amount matches expected
}

fn verify_irs_transfer(ctx: ScriptContext) -> Bool {
  // Verify transfer to IRS wallet
}