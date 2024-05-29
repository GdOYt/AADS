contract POBTokenERC20 is StandardToken {
    string public name = "Proof Of Brain";
    string public symbol = "PoB";
    uint8 constant public decimals = 18;
    uint256 constant public initialSupply = 2100*100000000;
	constructor() public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balances[msg.sender] = totalSupply;                
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}
