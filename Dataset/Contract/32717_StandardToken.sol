contract StandardToken is Token {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    using SafeMath for uint256;
    uint8 public decimals;                 
    uint256 endMintDate;
    address owner;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) minter;
    uint256 public _totalSupply;
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }
    modifier canMint() {
        require(endMintDate>now && minter[msg.sender]);
        _;
    }
    modifier canTransfer() {
        require(endMintDate<now);
        _;
    }
    function transfer(address _to, uint256 _value) canTransfer returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && _to!=0x0) {
            return doTransfer(msg.sender,_to,_value);
        }  else { return false; }
    }
    function doTransfer(address _from,address _to,uint256 _value) internal returns (bool success) {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) canTransfer returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && _to!=0x0 ) {
            doTransfer(_from,_to,_value);
            allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }
    function mint(address _to, uint256 _amount) canMint public returns (bool) {
        _totalSupply = _totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
    function setMinter(address _address,bool _canMint) onlyOwner public {
        minter[_address]=_canMint;
    } 
    function setEndMintDate(uint256 endDate) public{
        endMintDate=endDate;
    }
}
