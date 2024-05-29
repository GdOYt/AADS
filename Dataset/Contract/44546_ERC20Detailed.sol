contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _cap;
    constructor (string memory name, string memory symbol, uint8 decimals, uint256 cap) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _cap = cap;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function cap() public view returns (uint256) {
        return _cap;
    }
}
