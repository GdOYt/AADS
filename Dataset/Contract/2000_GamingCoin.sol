contract GamingCoin is StandardToken, Ownable {
    string public name = '';
    string public symbol = '';
    uint8 public  decimals = 0;
    uint256 public maxMintBlock = 0;
    event Mint(address indexed to, uint256 amount);
    function mint(address _to, uint256 _amount) onlyOwner  public returns (bool){
        require(maxMintBlock == 0);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(0,  _to, _amount); 
        maxMintBlock = 1;
        return true;
    }
    function multiTransfer(address[] destinations, uint256[] tokens) public returns (bool success){
        require(destinations.length > 0);
        require(destinations.length < 128);
        require(destinations.length == tokens.length);
        uint8 i = 0;
        uint256 totalTokensToTransfer = 0;
        for (i = 0; i < destinations.length; i++){
            require(tokens[i] > 0);            
            totalTokensToTransfer = totalTokensToTransfer.add(tokens[i]);
        }
        require (balances[msg.sender] > totalTokensToTransfer);        
        balances[msg.sender] = balances[msg.sender].sub(totalTokensToTransfer);
        for (i = 0; i < destinations.length; i++){
            balances[destinations[i]] = balances[destinations[i]].add(tokens[i]);
            emit Transfer(msg.sender, destinations[i], tokens[i]);
        }
        return true;
    }
    function GamingCoin(string _name , string _symbol , uint8 _decimals) public{
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}
