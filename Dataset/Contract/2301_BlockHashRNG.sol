contract BlockHashRNG is RNG {
    mapping (uint => uint) public randomNumber;  
    mapping (uint => uint) public reward;  
    function contribute(uint _block) public payable { reward[_block]+=msg.value; }
    function getRN(uint _block) public returns (uint RN) {
        RN=randomNumber[_block];
        if (RN==0){
            saveRN(_block);
            return randomNumber[_block];
        }
        else
            return RN;
    }
    function saveRN(uint _block) public {
        if (blockhash(_block) != 0x0)
            randomNumber[_block] = uint(blockhash(_block));
        if (randomNumber[_block] != 0) {  
            uint rewardToSend = reward[_block];
            reward[_block] = 0;
            msg.sender.send(rewardToSend);  
        }
    }
}
