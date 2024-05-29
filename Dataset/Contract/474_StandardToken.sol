contract StandardToken is Pausable {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 supply;
    uint256 public initialSupply;
    uint256 public totalSupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor() public {
        name = "Firetoken";
        symbol = "FPWR";
        decimals = 18;
        supply = 1800000000;
        initialSupply = supply * (10 ** uint256(decimals));
        totalSupply = initialSupply;
        balances[owner] = totalSupply;
        bountyTransfers();
    }
    function bountyTransfers() internal {
        address marketingReserve;
        address devteamReserve;
        address bountyReserve;
        address teamReserve;
        uint256 marketingToken;
        uint256 devteamToken;
        uint256 bountyToken;
        uint256 teamToken;
        marketingReserve = 0x00Fe8117437eeCB51782b703BD0272C14911ECdA;
        bountyReserve = 0x0089F23EeeCCF6bd677C050E59697D1f6feB6227;
        teamReserve = 0x00FD87f78843D7580a4c785A1A5aaD0862f6EB19;
        devteamReserve = 0x005D4Fe4DAf0440Eb17bc39534929B71a2a13F48;
        marketingToken = ( totalSupply * 10 ) / 100;
        bountyToken = ( totalSupply * 10 ) / 100;
        teamToken = ( totalSupply * 26 ) / 100;
        devteamToken = ( totalSupply * 10 ) / 100;
        balances[msg.sender] = totalSupply - marketingToken - teamToken - devteamToken - bountyToken;
        balances[teamReserve] = teamToken;
        balances[devteamReserve] = devteamToken;
        balances[bountyReserve] = bountyToken;
        balances[marketingReserve] = marketingToken;
        emit Transfer(msg.sender, marketingReserve, marketingToken);
        emit Transfer(msg.sender, bountyReserve, bountyToken);
        emit Transfer(msg.sender, teamReserve, teamToken);
        emit Transfer(msg.sender, devteamReserve, devteamToken);
    }
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public view whenNotPaused returns (uint256) {
        return balances[_owner];
    }
    function transferFrom( address _from, address _to, uint256 _value ) public whenNotPaused returns (bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view whenNotPaused returns (uint256) {
        return allowed[_owner][_spender];
    }
    function increaseApproval( address _spender, uint256 _addedValue ) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = ( allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval( address _spender, uint256 _subtractedValue ) public whenNotPaused returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
