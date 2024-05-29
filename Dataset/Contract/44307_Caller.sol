contract Caller{
   function callCallee(address _addr) public returns(bool){
       bytes4 methodId = bytes4(keccak256("increaseData(uint256)"));
       return _addr.call(methodId, 1);
   } 
}
