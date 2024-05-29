contract ArtBlockchainToken is StandardToken, Ownable {
    string public name = "Art Blockchain Token";
    string public symbol = "ARTCN";
    uint public decimals = 18;
    uint internal INITIAL_SUPPLY = (10 ** 9) * (10 ** decimals);
    mapping(address => uint256) private userLockedTokens;
    event Freeze(address indexed account, uint256 value);
    event UnFreeze(address indexed account, uint256 value);
    constructor(address _addressFounder) public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[_addressFounder] = INITIAL_SUPPLY;
        emit Transfer(0x0, _addressFounder, INITIAL_SUPPLY);
    }
    function balance(address _owner) internal view returns (uint256 token) {
        return balances[_owner].sub(userLockedTokens[_owner]);
    }
    function lockedTokens(address _owner) public view returns (uint256 token) {
        return userLockedTokens[_owner];
    }
	function freezeAccount(address _userAddress, uint256 _amount) onlyOwner public returns (bool success) {
        require(balance(_userAddress) >= _amount);
        userLockedTokens[_userAddress] = userLockedTokens[_userAddress].add(_amount);
        emit Freeze(_userAddress, _amount);
        return true;
    }
    function unfreezeAccount(address _userAddress, uint256 _amount) onlyOwner public returns (bool success) {
        require(userLockedTokens[_userAddress] >= _amount);
        userLockedTokens[_userAddress] = userLockedTokens[_userAddress].sub(_amount);
        emit UnFreeze(_userAddress, _amount);
        return true;
    }
     function transfer(address _to, uint256 _value)  public returns (bool success) {
        require(balance(msg.sender) >= _value);
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balance(_from) >= _value);
        return super.transferFrom(_from, _to, _value);
    }
}
