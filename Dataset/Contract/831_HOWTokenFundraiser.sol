contract HOWTokenFundraiser is MintableTokenFundraiser, IndividualCapsFundraiser, CappedFundraiser, RefundableFundraiser, GasPriceLimitFundraiser {
  HOWTokenSafe public tokenSafe;
  constructor()
    HasOwner(msg.sender)
    public
  {
    token = new HOWToken(
      msg.sender,   
      address(this)   
    );
    tokenSafe = new HOWTokenSafe(token);
    MintableToken(token).mint(address(tokenSafe), 78150000000000000000000000);
    initializeBasicFundraiser(
      1534169700,  
      1538143200,   
      50000,  
      0xCD3367edbf18C379FA6FBD9D2C206DbB83A816AD      
    );
    initializeIndividualCapsFundraiser(
      (0.01 ether),  
      (15 ether)   
    );
    initializeGasPriceLimitFundraiser(
        80000000000  
    );
    initializeCappedFundraiser(
      (1563 ether)  
    );
    initializeRefundableFundraiser(
      (313 ether)   
    );
  }
  function finalization() internal {
      super.finalization();
      MintableToken(token).disableMinting();
  }
}
