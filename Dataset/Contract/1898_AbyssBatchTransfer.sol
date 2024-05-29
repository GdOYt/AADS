contract AbyssBatchTransfer is Ownable {
    IERC20Token public token;
    constructor(address tokenAddress, address ownerAddress) public Ownable(ownerAddress) {
        token = IERC20Token(tokenAddress);
    }
    function batchTransfer(address[] recipients, uint256[] amounts) public onlyOwner {
        require(recipients.length == amounts.length);
        for(uint i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], amounts[i]));
        }
    }
}
