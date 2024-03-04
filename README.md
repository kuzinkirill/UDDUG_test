# UDDUG_test
Testing task

Unfortunately, for certain reasons, I did not have time to describe the tests in detail, so I will do it in words:

1) You need to check that if you pass a TokenId out of range, an error will be returned
2) When passing a tokenId that does not match the next valid one, an error should also be returned
(I made this because the following scenario is possible: from the moment the signature was drawn up, another user (or the same one) could perform a mint, as a result of which the tokenID ceases to be valid)
3) When maxSupply is reached, the opportunity to mint disappears
4) If we pass a message signed by another account to the function, the function will make a revert
5) If we try to use the same signature again, the result will be a revert
6) If we called the singleMint and signedSingleMint functions three or more times in total, the result will also be an error
7) If the user transmits his own signature, but with a different TokenId, then the result should also be an error
