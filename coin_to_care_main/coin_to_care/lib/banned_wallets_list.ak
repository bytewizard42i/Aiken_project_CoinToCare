use aiken/transaction/credential.{Address}

// neccesary improt statements

pub type BannedWallet {
  address: ByteArray,
}

//                Defines a list of banned wallet addresses

pub fn banned_wallets() -> List<BannedWallet> {
  [
    BannedWallet {
      address: #"abcdef1234567890abcdef1234567890abcdef1234567890abcdef12345678",
    },
    BannedWallet {
      address: #"90abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456",
    },
  ]
}
//                Add more banned addresses as needed
