contract blockHashNotReturned {
    function currentBlockHash() public returns (bytes32 b) {
        return blockhash(block.number); 
    }
    function currentBlockHashCst() constant public returns (bytes32 b) {
        return blockhash(block.number); 
    }
}
