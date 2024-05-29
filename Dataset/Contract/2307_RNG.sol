contract RNG{
    function contribute(uint _block) public payable;
    function requestRN(uint _block) public payable {
        contribute(_block);
    }
    function getRN(uint _block) public returns (uint RN);
    function getUncorrelatedRN(uint _block) public returns (uint RN) {
        uint baseRN=getRN(_block);
        if (baseRN==0)
            return 0;
        else
            return uint(keccak256(msg.sender,baseRN));
    }
 }
