contract AssetMin is SafeMin {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approve(address indexed from, address indexed spender, uint value);
    MultiAsset public multiAsset;
    bytes32 public symbol;
    string public name;
    function init(address _multiAsset, bytes32 _symbol) immutable(address(multiAsset)) returns(bool) {
        MultiAsset ma = MultiAsset(_multiAsset);
        if (!ma.isCreated(_symbol)) {
            return false;
        }
        multiAsset = ma;
        symbol = _symbol;
        return true;
    }
    function setName(string _name) returns(bool) {
        if (bytes(name).length != 0) {
            return false;
        }
        name = _name;
        return true;
    }
    modifier onlyMultiAsset() {
        if (msg.sender == address(multiAsset)) {
            _;
        }
    }
    function totalSupply() constant returns(uint) {
        return multiAsset.totalSupply(symbol);
    }
    function balanceOf(address _owner) constant returns(uint) {
        return multiAsset.balanceOf(_owner, symbol);
    }
    function allowance(address _from, address _spender) constant returns(uint) {
        return multiAsset.allowance(_from, _spender, symbol);
    }
    function transfer(address _to, uint _value) returns(bool) {
        return __transferWithReference(_to, _value, "");
    }
    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        return __transferWithReference(_to, _value, _reference);
    }
    function __transferWithReference(address _to, uint _value, string _reference) private returns(bool) {
        return _isHuman() ?
            multiAsset.proxyTransferWithReference(_to, _value, symbol, _reference) :
            multiAsset.transferFromWithReference(msg.sender, _to, _value, symbol, _reference);
    }
    function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
        return __transferToICAPWithReference(_icap, _value, "");
    }
    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
        return __transferToICAPWithReference(_icap, _value, _reference);
    }
    function __transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) private returns(bool) {
        return _isHuman() ?
            multiAsset.proxyTransferToICAPWithReference(_icap, _value, _reference) :
            multiAsset.transferFromToICAPWithReference(msg.sender, _icap, _value, _reference);
    }
    function approve(address _spender, uint _value) onlyHuman() returns(bool) {
        return multiAsset.proxyApprove(_spender, _value, symbol);
    }
    function setCosignerAddress(address _cosigner) onlyHuman() returns(bool) {
        return multiAsset.proxySetCosignerAddress(_cosigner, symbol);
    }
    function emitTransfer(address _from, address _to, uint _value) onlyMultiAsset() {
        Transfer(_from, _to, _value);
    }
    function emitApprove(address _from, address _spender, uint _value) onlyMultiAsset() {
        Approve(_from, _spender, _value);
    }
    function sendToOwner() returns(bool) {
        address owner = multiAsset.owner(symbol);
        return multiAsset.transfer(owner, balanceOf(owner), symbol);
    }
    function decimals() constant returns(uint8) {
        return multiAsset.baseUnit(symbol);
    }
}
