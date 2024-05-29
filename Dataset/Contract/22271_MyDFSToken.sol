contract MyDFSToken is StandardToken {
    string public name = "MyDFS Token";
    uint8 public decimals = 6;
    string public symbol = "MyDFS";
    string public version = 'H1.0';
    uint256 public totalSupply;
    function () external {
        revert();
    } 
    function MyDFSToken() public {
        totalSupply = 125 * 1e12;
        balances[msg.sender] = totalSupply;
    }
    function name() public view returns (string _name) {
        return name;
    }
    function symbol() public view returns (string _symbol) {
        return symbol;
    }
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }
    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }
}
