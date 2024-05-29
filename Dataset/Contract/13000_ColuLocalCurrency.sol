contract ColuLocalCurrency is Ownable, Standard677Token, TokenHolder {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    string public tokenURI;
    event TokenURIChanged(string newTokenURI);
    function ColuLocalCurrency(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, string _tokenURI) public {
        require(_totalSupply != 0);
        require(bytes(_name).length != 0);
        require(bytes(_symbol).length != 0);
        totalSupply = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        tokenURI = _tokenURI;
        balances[msg.sender] = totalSupply;
    }
    function setTokenURI(string _tokenURI) public onlyOwner {
      tokenURI = _tokenURI;
      TokenURIChanged(_tokenURI);
    }
}
