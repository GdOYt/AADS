contract GMCToken is StandardToken {
    struct GiftData {
        address from;
        uint256 value;
        string message;
    }
    function () {
        revert();
    }
    string public name;                    
    string public symbol;                  
    string public version = 'H1.0';        
    mapping (address => mapping (uint256 => GiftData)) private gifts;
    mapping (address => uint256 ) private giftsCounter;
    function GMCToken(address _wallet) {
        uint256 initialSupply = 2000000;
        endMintDate=now+4 weeks;
        owner=msg.sender;
        minter[_wallet]=true;
        minter[msg.sender]=true;
        mint(_wallet,initialSupply.div(2));
        mint(msg.sender,initialSupply.div(2));
        name = "Good Mood Coin";                                    
        decimals = 4;                             
        symbol = "GMC";                                
    }
    function sendGift(address _to,uint256 _value,string _msg) payable public returns  (bool success){
        uint256 counter=giftsCounter[_to];
        gifts[_to][counter]=(GiftData({
            from:msg.sender,
            value:_value,
            message:_msg
        }));
        giftsCounter[_to]=giftsCounter[_to].inc();
        return doTransfer(msg.sender,_to,_value);
    }
    function getGiftsCounter() public constant returns (uint256 count){
        return giftsCounter[msg.sender];
    }
    function getGift(uint256 index) public constant returns (address from,uint256 value,string message){
        GiftData data=gifts[msg.sender][index];
        return (data.from,data.value,data.message);
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
