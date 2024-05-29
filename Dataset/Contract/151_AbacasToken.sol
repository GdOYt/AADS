contract AbacasToken is DetailedERC20("AbacasXchange [Abacas] Token", "ABCS", 9), PausableToken {
    constructor(address _allowedTransferWallet) PausableToken(_allowedTransferWallet) public {
        totalSupply_ = 100e6 * (uint256(10) ** decimals);
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
}
