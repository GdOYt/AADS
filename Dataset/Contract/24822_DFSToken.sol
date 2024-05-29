contract DFSToken is MintableToken, ERC827Token, NoOwner {
    string public symbol = 'DFS';
    string public name = 'Digital Fantasy Sports';
    uint8 public constant decimals = 18;
    bool public transferEnabled;     
    function setTransferEnabled(bool enable) onlyOwner public {
        transferEnabled = enable;
    }
    modifier canTransfer() {
        require( transferEnabled || msg.sender == owner);
        _;
    }
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function transfer(address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {
        return super.transfer(_to, _value, _data);
    }
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value, _data);
    }
}
