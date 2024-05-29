contract Token {
    mapping (address => uint256) public balances;
    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = _initialSupply;
    }
    function buy() public payable {
        balances[msg.sender] += msg.value;  
    }
    function transfer(address _to, uint256 _value) public {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);   
        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }
    function withdraw(uint _amount) public {     
        require(balances[msg.sender] >= _amount);
        if(msg.sender.call.value(_amount)()) {
            balances[msg.sender] -= _amount;        
        }       
    }    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}