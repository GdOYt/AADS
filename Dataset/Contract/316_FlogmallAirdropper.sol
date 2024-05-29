contract FlogmallAirdropper is Ownable {
    using SafeMath for uint;
    ERC20 public token;
    uint public multiplier;
    function FlogmallAirdropper(address tokenAddress, uint decimals) public {
        require(decimals <= 77);   
        token = ERC20(tokenAddress);
        multiplier = 10**decimals;
    }
    function airdrop(address source, address[] dests, uint[] values) public onlyOwner {
        require(dests.length == values.length);
        for (uint256 i = 0; i < dests.length; i++) {
            require(token.transferFrom(source, dests[i], values[i].mul(multiplier)));
        }
    }
    function returnTokens() public onlyOwner {
        token.transfer(owner, token.balanceOf(this));
    }
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}
