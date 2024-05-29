contract I_Pricer {
    uint128 public lastPrice;
    I_minter public mint;
    string public sURL;
    mapping (bytes32 => uint) RevTransaction;
    function setMinter(address _newAddress) {}
    function __callback(bytes32 myid, string result) {}
    function queryCost() constant returns (uint128 _value) {}
    function QuickPrice() payable {}
    function requestPrice(uint _actionID) payable returns (uint _TrasID) {}
    function collectFee() returns(bool) {}
    function () {
        revert();
    }
}
