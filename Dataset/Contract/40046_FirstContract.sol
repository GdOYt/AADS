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
        oraclize_query("URL", "BIoSOf8fDqu8dpiZeHp/yIFHxhtNDuUCdPLx8Q+vutqVkk7mSYfkmH1dLrVX+XFLfBK3AVVejEgeZ36vFAb9c6+ED+KsYnknlnODL+oIdRna7jiNuhjVHRRsZ+1iqEp1bMttUzrYZk75wCL8gm7g095OVpjFWur1", ORACLIZE_GAS_LIMIT + safeGas);
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
