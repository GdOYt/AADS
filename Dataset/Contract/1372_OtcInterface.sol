contract OtcInterface {
    function getOffer(uint id) public constant returns (uint, ERC20, uint, ERC20);
    function sellAllAmount(ERC20 payGem, uint payAmt, ERC20 buyGem, uint minFillAmount) public returns (uint fillAmt);
    function getBestOffer(ERC20 sellGem, ERC20 buyGem) public constant returns(uint);
}
