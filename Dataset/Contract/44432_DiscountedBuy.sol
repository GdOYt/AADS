contract DiscountedBuy {
    uint public basePrice = 1 ether;
    mapping (address => uint) public objectBought;
    function buy() payable {
        require(msg.value * (1 + objectBought[msg.sender]) == basePrice);
        objectBought[msg.sender]+=1;
    }
    function price() constant returns(uint price) {
        return basePrice/(1 + objectBought[msg.sender]);
    }
}
