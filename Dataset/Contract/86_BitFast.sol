contract BitFast is StandardToken, BurnableToken {
    string public constant name = "BitFast";
    string public constant symbol = "FAST";
    uint32 public constant decimals = 8;
    uint256 public INITIAL_SUPPLY = 5000000000000000;
    address public CrowdsaleAddress;
    bool public lockTransfers = true;
    event AcceptToken(address indexed from, uint256 value);
    constructor(address _CrowdsaleAddress) public {
        CrowdsaleAddress = _CrowdsaleAddress;
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;      
    }
    modifier onlyOwner() {
        require(msg.sender == CrowdsaleAddress);
        _;
    }
    function transfer(address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, "Transfers are prohibited in Crowdsale period");
        }
        return super.transfer(_to,_value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, "Transfers are prohibited in Crowdsale period");
        }
        return super.transferFrom(_from,_to,_value);
    }
    function acceptTokens(address _from, uint256 _value) public onlyOwner returns (bool){
        require (balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit AcceptToken(_from, _value);
        return true;
    }
    function transferTokensFromSpecialAddress(address _from, address _to, uint256 _value) public onlyOwner returns (bool){
        require (balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function lockTransfer(bool _lock) public onlyOwner {
        lockTransfers = _lock;
    }
    function() external payable {
        revert("The token contract don`t receive ether");
    }  
}
