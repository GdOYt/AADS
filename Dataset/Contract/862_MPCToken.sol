contract MPCToken is PausableToken {
    string public name = "Miner Pass Card";
    string public symbol = "MPC";
    uint8 public decimals = 18;
    constructor() public {
        totalSupply_ = 2000000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
    function batchTransfer(address[] _to, uint256[] value) public whenNotPaused returns(bool success){
        require(_to.length == value.length);
        for( uint256 i = 0; i < _to.length; i++ ){
            transfer(_to[i],value[i]);
        }
        return true;
    }
}
