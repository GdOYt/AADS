contract DIoTNetworkShare is StandardToken, Owned {
    string public name = "Decentralized IoT Network Share";
    uint256 public decimals = 18;
    string public symbol = "DNS";
    string public version = "H0.1";
    function DIoTNetworkShare() public {
        totalSupply = (10 ** 9) * (10 ** decimals);
        balances[msg.sender] = totalSupply;
    }
    function() public payable {
        revert();
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if (!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { 
            revert(); 
        }
        return true;
    }
}
