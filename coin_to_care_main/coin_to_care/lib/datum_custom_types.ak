// *** Datum Custom Types ***

use aiken/hash.{Blake2b_224, Hash}
use aiken/primitive.{ByteArray, Int}
use aiken/transaction/credential.{VerificationKey}

// Define the My_datum type
pub type My_datum {
  owner: Hash<Blake2b_224, VerificationKey>,
  // The owner's public key hash
  signer: ByteArray,
  // The signer's public key or identifier
  count: Int,
}
// A counter for tracking purposes
