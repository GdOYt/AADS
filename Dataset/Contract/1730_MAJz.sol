contract MAJz is BasicToken, Ownership {
    using SafeMath for uint256;
    string public _symbol;
    string public _name;
    uint256 public _decimals;
    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    constructor() public{
        _symbol = "MAZ";
        _name = "MAJz";
        _decimals = 18;
        _totalSupply = 560000000000000000000000000;
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address targetAddress) public view returns (uint256) {
        return _balances[targetAddress];
    }
    function transfer(address targetAddress, uint256 value) validDestination(targetAddress) public returns (bool) {
        _balances[msg.sender] = SafeMath.sub(_balances[msg.sender], value); 
        _balances[targetAddress] = SafeMath.add(_balances[targetAddress], value);
        emit Transfer(msg.sender, targetAddress, value); 
        return true; 
    }
    function burnTokens(uint256 value) public onlyOwner returns (bool){
        _balances[_owner] = SafeMath.sub(_balances[_owner], value); 
        _totalSupply = SafeMath.sub(_totalSupply, value); 
        emit BurnTokens(value);
        return true;
    }
    function emitTokens(uint256 value) public onlyOwner returns (bool){
        _balances[_owner] = SafeMath.add(_balances[_owner], value); 
        _totalSupply = SafeMath.add(_totalSupply, value);
        emit EmitTokens(value);
        return true;
    }
    function revertTransfer (address targetAddress, uint256 value) public onlyOwner returns (bool){
        _balances[targetAddress] = SafeMath.sub(_balances[targetAddress], value);
        _balances[_owner] = SafeMath.add(_balances[_owner], value);
        emit RevertTransfer(targetAddress, value);
        return true;
    }
    event BurnTokens(uint256 value);
    event EmitTokens(uint256 value);
    event RevertTransfer(address targetAddress, uint256 value);
}
