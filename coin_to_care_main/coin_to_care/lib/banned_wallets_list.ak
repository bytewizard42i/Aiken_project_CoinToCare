// *** This file is used to store a list of banned wallet addresses ***

use aiken/transaction/credential.{Address}

//                neccesary import statements

// Defined custom Datum type, containing the owner's public key hash. Thi code is located in the datum_custom_types.ak file

// Define custom Redeemer type, containing a user input message. Code is located in the redeemer_custom_types.ak file

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
//                Defines a known list of banned wallet addresses
//                Add more banned addresses as needed
