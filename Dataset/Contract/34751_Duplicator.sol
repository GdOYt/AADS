contract Duplicator is Owned, HumanStandardToken {
    function Duplicator() HumanStandardToken(0, "Duplicator", 0, "DUP") {}
    function () public payable {
        buy();
    }
    function buy() public payable {
        totalSupply += msg.value;
        balances[msg.sender] += msg.value;
    }
    function duplicate() public {
        totalSupply += balances[msg.sender];
        balances[msg.sender] += balances[msg.sender];
    }
    function sellAll() public {
        uint amountToSell = balances[msg.sender];
        totalSupply -= amountToSell;
        balances[msg.sender] -= amountToSell;
        msg.sender.transfer(amountToSell);
        require(this.balance == totalSupply);
    }
    function migrate(address newContract) public onlyOwner {
        selfdestruct(newContract);
    }
}
