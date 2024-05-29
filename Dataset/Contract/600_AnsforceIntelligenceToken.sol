contract AnsforceIntelligenceToken is Owned, ERC20Token {
    constructor() public {
    }
    function init(uint256 _supply, address _vault) public onlyOwner {
        require(totalSupply == 0);
        require(_supply > 0);
        require(_vault != address(0));
        totalSupply = _supply;
        balanceOf[_vault] = totalSupply;
    }
    bool public stopped = false;
    modifier isRunning {
        require (!stopped);
        _;
    }
    function transfer(address to, uint256 value) isRunning public {
        ERC20Token.transfer(to, value);
    }
    function stop() public onlyOwner {
        stopped = true;
    }
    function start() public onlyOwner {
        stopped = false;
    }
    mapping (address => uint256) public freezeOf;
    event Freeze(address indexed target, uint256 value);
    event Unfreeze(address indexed target, uint256 value);
    function freeze(address target, uint256 _value) public onlyOwner returns (bool success) {
        require( _value > 0 );
        balanceOf[target] = SafeMath.sub(balanceOf[target], _value);
        freezeOf[target] = SafeMath.add(freezeOf[target], _value);
        emit Freeze(target, _value);
        return true;
    }
    function unfreeze(address target, uint256 _value) public onlyOwner returns (bool success) {
        require( _value > 0 );
        freezeOf[target] = SafeMath.sub(freezeOf[target], _value);
        balanceOf[target] = SafeMath.add(balanceOf[target], _value);
        emit Unfreeze(target, _value);
        return true;
    }
}
