contract SelfDesctructionContract {
   address public owner;
   string  public someValue;
   modifier ownerRestricted {
      require(owner == msg.sender);
      _;
   } 
   function SelfDesctructionContract() {
      owner = msg.sender;
   }
   function setSomeValue(string value){
      someValue = value;
   } 
   function destroyContract() ownerRestricted {
     selfdestruct(owner);
   }
}
