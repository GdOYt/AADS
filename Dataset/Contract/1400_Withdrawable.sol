contract Withdrawable is PermissionGroups {
    event TokenWithdraw(ERC20 token, uint amount, address sendTo);
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }
    event EtherWithdraw(uint amount, address sendTo);
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}
