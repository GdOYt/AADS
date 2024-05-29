contract LineageCode is StandardToken {
    string public name = 'LineageCode';
    string public symbol = 'LIN';
    uint public decimals = 10;
    uint public INITIAL_SUPPLY = 80 * 100000000 * (10 ** decimals);
    address owner;
    bool public released = false;
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        owner = msg.sender;
    }
    function release() public {
        require(owner == msg.sender);
        require(!released);
        released = true;
    }
    function lock() public {
        require(owner == msg.sender);
        require(released);
        released = false;
    }
    function get_Release() view public returns (bool) {
        return released;
    }
    modifier onlyReleased() {
        if (owner != msg.sender)
          require(released);
        _;
    }
    function transfer(address to, uint256 value) public onlyReleased returns (bool) {
        super.transfer(to, value);
    }
    function allowance(address _owner, address _spender) public onlyReleased view returns (uint256) {
        super.allowance(_owner, _spender);
    }
    function transferFrom(address from, address to, uint256 value) public onlyReleased returns (bool) {
        super.transferFrom(from, to, value);
    }
    function approve(address spender, uint256 value) public onlyReleased returns (bool) {
        super.approve(spender, value);
    }
}
