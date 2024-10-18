//  Where the hell does the hash come from?
// Import the needed hashing functionality
use aiken/hash.{Blake2b_224, Hash, hash_key} 
use aiken/transaction/credential.{VerificationKey, Address, Credential}
use aiken/builtin

// Function to get address hash from a transaction input
fn get_address_hash(address: Address) -> Hash<Blake2b_224> {
  when address.payment_credential is {
    // For normal wallet addresses (VerificationKey credentials)
    VerificationKey(pubkey_hash) -> pubkey_hash
    // For script addresses
    ScriptCredential(script_hash) -> script_hash
  }
}

// Example usage in validator
validator {
  fn check_donor_and_where(donor_info: DonorInfo, redeemer: Data, ctx: ScriptContext) -> Bool {
    when ctx.purpose is {
      Spend(_) -> {
        let tx: Transaction = ctx.transaction
        // Get the first input's address
        let sender_address = tx.inputs[0].address
        // Get the hash of the sender's address
        let sender_hash = get_address_hash(sender_address)
        
        // Now you can use the hash to compare or verify
        // For example, to check against a known address hash:
        let known_hash: Hash<Blake2b_224> = #"1234..."
        
        if sender_hash == known_hash {
          // Do something...
        }

        // Or to convert to ByteArray for storage/comparison
        let hash_bytes: ByteArray = hash_key(sender_hash)
        
        // Rest of your validation logic...
      }
      _ -> False
    }
  }
}
// End of Hashing Functionality lesson





// Import required modules:
// - Blake2b_224 for hashing functionality
// - Hash type for working with hashed values
use aiken/hash.{Blake2b_224, Hash}
// List module for working with lists/arrays
use aiken/list
// Transaction related types for blockchain operations
use aiken/transaction.{Transaction, ScriptContext, Spend}
// Credential types for working with addresses and verification
use aiken/transaction/credential.{VerificationKey, Address}

// Define a custom type for donor information
// This structure holds a single boolean flag indicating if the donor is US-based
type DonorInfo {
  is_us_based: Bool,
}

// Define a custom type for banned wallet addresses
// This structure holds a ByteArray representing a wallet address
type BannedWallet {
  address: ByteArray,
}

// Define the IRS wallet address as a constant
// ByteArray format: #"hex_string"
// In production, replace this with the actual IRS wallet address
const irs_wallet: ByteArray = #"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"

// Main validator function
// This is the entry point of our smart contract
validator {
  // check_donor_and_where takes three parameters:
  // - donor_info: Information about the donor (US-based status)
  // - redeemer: Additional data provided during transaction (unused in this case)
  // - ctx: The transaction context containing all transaction details
  fn check_donor_and_where(donor_info: DonorInfo, redeemer: Data, ctx: ScriptContext) -> Bool {
    // Pattern match on the context purpose
    when ctx.purpose is {
      // Only proceed if this is a spending transaction
      Spend(_) -> {
        // Extract the full transaction from context
        let tx: Transaction = ctx.transaction
        // Get the sender's address from the first input
        let sender_address = tx.inputs[0].address
        
        // Get the list of banned wallets and check if sender is banned
        let banned_wallets: List<BannedWallet> = read_banned_wallets()
        // Use list.any to check if sender's address matches any banned address
        let is_banned = list.any(
          banned_wallets,
          fn(banned) { banned.address == sender_address },
        )
        
        // Decision tree:
        // If wallet is banned OR donor is US-based -> Send to IRS
        // Otherwise -> Return to sender
        if is_banned || donor_info.is_us_based {
          verify_transfer_to_irs(tx)
        } else {
          verify_return_to_sender(tx, sender_address)
        }
      }
      // Reject all other transaction purposes
      _ -> False
    }
  }
}

// Helper function to verify transfer to IRS wallet
// Takes a transaction and returns boolean indicating if transfer is valid
fn verify_transfer_to_irs(tx: Transaction) -> Bool {
  // Get all transaction outputs
  let outputs = tx.outputs
  // Check if any output is going to the IRS wallet address
  list.any(
    outputs,
    fn(output) { output.address == irs_wallet },
  )
}

// Helper function to verify return to sender
// Takes transaction and sender's address, returns boolean for validity
fn verify_return_to_sender(tx: Transaction, sender: ByteArray) -> Bool {
  // Get all transaction outputs
  let outputs = tx.outputs
  // Check if any output is returning to sender AND has valid signature
  list.any(
    outputs,
    fn(output) {
      output.address == sender &&
        verify_signature(output)
    },
  )
}

// Helper function to verify transaction signatures
// Takes a transaction output and returns boolean for signature validity
fn verify_signature(output: TransactionOutput) -> Bool {
  // Pattern match on the payment credential type
  when output.address.payment_credential is {
    // If it's a verification key credential
    VerificationKey(vkey) -> True  // TODO: Implement actual signature verification
    // Reject all other credential types
    _ -> False
  }
}

// === Test Section ===

use aiken/test.{test, expect, should}

// Test complete donation flow for non-US donor
test complete_donation_flow() {
  // Setup test parameters
  let initial_balance = 1000000  // 1 ADA = 1,000,000 Lovelace
  let fee = 2000                 // Transaction fee
  let donor_info = DonorInfo { is_us_based: False }
  
  // Test Step 1: Initial donation setup
  test_step("1. Initialize donation") {
    let tx = setup_donation_tx(initial_balance)
    let ctx = mock_context(tx)
    
    check_donor_and_where(donor_info, (), ctx) |> should.be_ok()
  }
  
  // Test Step 2: Verify correct amount is returned after fees
  test_step("2. Verify balance after fees") {
    let expected_return = initial_balance - fee
    let tx = setup_return_tx(expected_return)
    let ctx = mock_context(tx)
    
    verify_return_amount(ctx, expected_return) |> should.be_ok()
  }
}

// Test complete donation flow for US-based donor
test complete_us_based_flow() {
  // Setup test parameters
  let initial_balance = 1000000
  let donor_info = DonorInfo { is_us_based: True }
  
  // Test Step 1: Initial US-based donation
  test_step("1. Initialize US-based donation") {
    let tx = setup_donation_tx(initial_balance)
    let ctx = mock_context(tx)
    
    check_donor_and_where(donor_info, (), ctx) |> should.be_ok()
  }
  
  // Test Step 2: Verify funds are sent to IRS
  test_step("2. Verify IRS transfer") {
    let tx = setup_irs_transfer_tx(initial_balance)
    let ctx = mock_context(tx)
    
    verify_irs_transfer(ctx) |> should.be_ok()
  }
}

// === Test Helper Functions ===
// These functions need to be implemented based on your specific testing needs

fn setup_donation_tx(amount: Int) -> Transaction {
  // TODO: Implement creation of test donation transaction
}

fn setup_return_tx(amount: Int) -> Transaction {
  // TODO: Implement creation of test return transaction
}

fn setup_irs_transfer_tx(amount: Int) -> Transaction {
  // TODO: Implement creation of test IRS transfer transaction
}

fn verify_return_amount(ctx: ScriptContext, expected: Int) -> Bool {
  // TODO: Implement verification of returned amount
}

fn verify_irs_transfer(ctx: ScriptContext) -> Bool {
  // TODO: Implement verification of IRS transfer
}