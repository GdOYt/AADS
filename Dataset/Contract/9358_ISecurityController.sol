contract ISecurityController {
    function balanceOf(address _a) public view returns (uint);
    function totalSupply() public view returns (uint);
    function isTransferAuthorized(address _from, address _to) public view returns (bool);
    function setTransferAuthorized(address from, address to, uint expiry) public;
    function transfer(address _from, address _to, uint _value) public returns (bool success);
    function transferFrom(address _spender, address _from, address _to, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint);
    function approve(address _owner, address _spender, uint _value) public returns (bool success);
    function increaseApproval(address _owner, address _spender, uint _addedValue) public returns (bool success);
    function decreaseApproval(address _owner, address _spender, uint _subtractedValue) public returns (bool success);
    function burn(address _owner, uint _amount) public;
    function ledgerTransfer(address from, address to, uint val) public;
    function setLedger(address _ledger) public;
    function setSale(address _sale) public;
    function setToken(address _token) public;
    function setAffiliateList(address _affiliateList) public;
}
