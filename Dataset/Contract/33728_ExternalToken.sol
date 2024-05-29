contract ExternalToken is NotifyingTokenImpl {
    event Mint(address indexed to, uint256 value, bytes data);
    event Burn(address indexed burner, uint256 value, bytes data);
    modifier onlyMinter() {
        checkMinter();
        _;
    }
    function checkMinter() internal;
    function mint(address _to, uint256 _value, bytes _mintData) onlyMinter public returns (bool) {
        _mint(_to, _value, _mintData);
        emitTransferWithData(0x0, _to, _value, "");
        return true;
    }
    function mintAndCall(address _to, uint256 _value, bytes _mintData, bytes _data) onlyMinter public returns (bool) {
        _mint(_to, _value, _mintData);
        emitTransferWithData(0x0, _to, _value, _data);
        TokenReceiver(_to).onTokenTransfer(0x0, _value, _data);
        return true;
    }
    function _mint(address _to, uint256 _value, bytes _data) private {
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        Mint(_to, _value, _data);
    }
    function burn(uint256 _value, bytes _data) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        checkBurnData(_value, _data);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value, _data);
    }
    function checkBurnData(uint256 _value, bytes _data) internal {
    }
}
