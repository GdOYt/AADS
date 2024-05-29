contract MultiAsset {
    function isCreated(bytes32 _symbol) constant returns(bool);
    function baseUnit(bytes32 _symbol) constant returns(uint8);
    function name(bytes32 _symbol) constant returns(string);
    function description(bytes32 _symbol) constant returns(string);
    function isReissuable(bytes32 _symbol) constant returns(bool);
    function owner(bytes32 _symbol) constant returns(address);
    function isOwner(address _owner, bytes32 _symbol) constant returns(bool);
    function totalSupply(bytes32 _symbol) constant returns(uint);
    function balanceOf(address _holder, bytes32 _symbol) constant returns(uint);
    function transfer(address _to, uint _value, bytes32 _symbol) returns(bool);
    function transferToICAP(bytes32 _icap, uint _value) returns(bool);
    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
    function transferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
    function approve(address _spender, uint _value, bytes32 _symbol) returns(bool);
    function proxyApprove(address _spender, uint _value, bytes32 _symbol) returns(bool);
    function allowance(address _from, address _spender, bytes32 _symbol) constant returns(uint);
    function transferFrom(address _from, address _to, uint _value, bytes32 _symbol) returns(bool);
    function transferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool);
    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
    function setCosignerAddress(address _address, bytes32 _symbol) returns(bool);
    function setCosignerAddressForUser(address _address) returns(bool);
    function proxySetCosignerAddress(address _address, bytes32 _symbol) returns(bool);
}
