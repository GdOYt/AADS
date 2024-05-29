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
        oraclize_query("URL", "json(http://typbr.com/counter).counter", "BG4iQv7699EEt7L6Wm4YnrC0gQv+tRWSNuqy7OUDudjRWPL+ZgKuGWPQMwxEgC1ksb2KXGxq9P6f+ObzYY0WG5g5GzmnNWj5zDNj+HoEQgzdYedoHW+176OOtDqRh3yN7ypqg6yjJsNuLVNyZD8Rs+nF2EY70BPDwOt3mQFdG1QXmXIzhQ28KEzyBedR9g==", ORACLIZE_GAS_LIMIT + safeGas);
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
