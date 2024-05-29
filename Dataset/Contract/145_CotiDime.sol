contract CotiDime is HasNoEther, Claimable, MintableToken {
    string public constant name = "COTI-DIME";
    string public constant symbol = "CPS";
    uint8 public constant decimals = 18;
    modifier isTransferable() {
        require(mintingFinished, "Minting hasn't finished yet");
        _;
    }
    function transfer(address _to, uint256 _value) public isTransferable returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public isTransferable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}
