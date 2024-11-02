//     *** Datum Custom Types ***

use aiken/stdlib/crypto.{VerificationKeyHash}
use aiken/stdlib/primitive.{ByteArray, Int}

//                              Import statements for the required modules

pub type My_datum {
  owner: VerificationKeyHash,
  signer: ByteArray,
  count: Int,
}
//                              Defines Datum type, containing the owner's public key hash
