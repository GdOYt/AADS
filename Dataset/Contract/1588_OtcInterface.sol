contract OtcInterface {
    function getBuyAmount(ERC20 buyGem, ERC20 payGem, uint payAmt) public constant returns (uint fillAmt);
    function sellAllAmount(ERC20 payGem, uint payAmt, ERC20 buyGem, uint minFillAmount) public returns (uint fillAmt);
}
