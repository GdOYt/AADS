contract InseeCoin is ISStop, StandardToken{
    string public name = "Insee Coin";
    uint8 public decimals = 18;
    string public symbol = "SEE";
    string public version = "v0.1";
    uint256 public initialAmount = (10 ** 10) * (10 ** 18);
    event Destroy(address from, uint value);
    function InseeCoin() public {
        balances[msg.sender] = initialAmount;    
        totalSupply_ = initialAmount;               
    }
    function transfer(address dst, uint wad) public stoppable  returns (bool) {
        return super.transfer(dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) public stoppable  returns (bool) {
        return super.transferFrom(src, dst, wad);
    }
    function approve(address guy, uint wad) public stoppable  returns (bool) {
        return super.approve(guy, wad);
    }
    function destroy(uint256 _amount) external onlyOwner stoppable  returns (bool success){
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Destroy(msg.sender, _amount);
        return true;
    }
     function setName(string name_) public onlyOwner{
        name = name_;
    }
}
