contract Comission is Mortal {
    address public ledger;
    bytes32 public taxman;
    uint    public taxPerc;
    function Comission(address _ledger, bytes32 _taxman, uint _taxPerc) {
        ledger  = _ledger;
        taxman  = _taxman;
        taxPerc = _taxPerc;
    }
    function process(bytes32 _destination) payable returns (bool) {
        if (msg.value < 100) throw;
        var tax = msg.value * taxPerc / 100; 
        var refill = bytes4(sha3("refill(bytes32)")); 
        if ( !ledger.call.value(tax)(refill, taxman)
          || !ledger.call.value(msg.value - tax)(refill, _destination)
           ) throw;
        return true;
    }
}
