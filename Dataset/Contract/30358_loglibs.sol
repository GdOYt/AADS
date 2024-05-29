contract loglibs {
   mapping (address => uint256) public sendList;
   function logSendEvent() payable public{
        sendList[msg.sender] = 1 ether;
   }
}
