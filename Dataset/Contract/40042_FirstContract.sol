contract FirstContract is usingOraclize {
    address owner;
    uint constant ORACLIZE_GAS_LIMIT = 125000;
    uint public counter  = 0;
    uint public errCounter = 0;
    uint safeGas = 25000;
    function FirstContract() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
    }
    function() {
        errCounter++;
    }
    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }
    modifier onlyOwner {
        if (owner != msg.sender) throw;
        _;
    }
    function changeGasLimitOfSafeSend(uint newGasLimit) onlyOwner {
        safeGas = newGasLimit;
    }
    function count() payable onlyOwner {
        oraclize_query("URL", "json(http://typbr.com/counter).counter", "BON4oYqHyydPJWXhq8ElREZ4XbwVJaT/7EkJhTABWGAh9eX86sNUamnllJ0w6bHyUFUKb49yxX9YLXxG/CQVZ1bMig9RS4h94ihW9hUftduqGL2+j9njTmlYgw80t5LRQMAMO2Wk5qEL+T77CoQoQV1vCw==", ORACLIZE_GAS_LIMIT + safeGas);
    }
   function invest() payable {
   }
   function __callback (bytes32 myid, string result, bytes proof) payable onlyOraclize {
         counter = parseInt(result);
    }
    function safeSend(address addr, uint value) private {
        if (this.balance < value) {
            throw;
        }
        if (!(addr.call.gas(safeGas).value(value)())) {
            throw;
        }
    }   
   function divest(uint amount) payable onlyOwner {
       safeSend(owner, amount);
   }
   function destruct() payable onlyOwner {
       selfdestruct(owner);
   }
}
