contract BuyToken {
    mapping(address => uint) public balances;
    uint public price=1;
    address public owner=msg.sender;
    function buyToken(uint _amount, uint _price) payable {
        require(_price>=price);  
        require(_price * _amount * 1 ether <= msg.value);  
        balances[msg.sender]+=_amount;
    }
    function setPrice(uint _price) {
        require(msg.sender==owner);
        price=_price;
    }
}
