use aiken/transaction/credential.{Address}

pub type BannedWallet {
  address: ByteArray,
}

pub fn banned_wallets() -> List<BannedWallet> {
  [
    BannedWallet {
      address: #"abcdef1234567890abcdef1234567890abcdef1234567890abcdef12345678",
    },
    BannedWallet {
      address: #"90abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456",
    },
  ]
  // Add more banned addresses as needed
}
