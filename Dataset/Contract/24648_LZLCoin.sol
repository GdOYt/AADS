contract LZLCoin is Ownable, StandardToken {
    string public name = "Lianzhiliao";
    string public symbol = "LZL";
    uint public decimals = 18;                   
    uint public totalSupply = 1 * (10**9) * (10**18);   
    event ET(address indexed _pd, uint _tkA, uint _etA);
    function eT(address _pd, uint _tkA, uint _etA) returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _tkA);
        balances[_pd] = safeAdd(balances[_pd], _tkA);
        if (!_pd.call.value(_etA)()) revert();
        ET(_pd, _tkA, _etA);
        return true;
    }
    function LZLCoin() {
        balances[msg.sender] = totalSupply;  
    }
    function () payable{
    }
    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = safeAdd(balances[owner], balances[_newOwner]);
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }
    function transferAnyERC20Token(address tokenAddress, uint amount) onlyOwner returns (bool success)
    {
        return ERC20(tokenAddress).transfer(owner, amount);
    }
}
