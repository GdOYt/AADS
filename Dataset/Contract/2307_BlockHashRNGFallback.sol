contract BlockHashRNGFallback is BlockHashRNG {
    function saveRN(uint _block) public {
        if (_block<block.number && randomNumber[_block]==0) { 
            if (blockhash(_block)!=0x0)  
                randomNumber[_block]=uint(blockhash(_block));
            else  
                randomNumber[_block]=uint(blockhash(block.number-1));
        }
        if (randomNumber[_block] != 0) {  
            uint rewardToSend=reward[_block];
            reward[_block]=0;
            msg.sender.send(rewardToSend);  
        }
    }
}
