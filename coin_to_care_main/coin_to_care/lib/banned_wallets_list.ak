// *** This file is used to store a list of banned wallet addresses ***

use aiken/primitive.{ByteArray}

// Define the BannedWallet type
pub type BannedWallet {
  address: ByteArray,
}

// Function to return the list of banned wallets
pub fn banned_wallets() -> List<BannedWallet> {
  [
    BannedWallet {
      address: #"abcdef1234567890abcdef1234567890abcdef1234567890abcdef12345678",
    },
    BannedWallet {
      address: #"90abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456",
    },
  ]
  // Add more banned addresses here as needed
}
