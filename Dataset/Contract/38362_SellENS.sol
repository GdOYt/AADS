contract SellENS {
  SellENSFactory factory;
  function SellENS(){
    factory = SellENSFactory(msg.sender);
  }
  function () payable {
    factory.transfer(msg.value);
    factory.sell_label(msg.sender, msg.value);
  }
}
