contract SweetTokenLogic is TokenLogic {
    function SweetTokenLogic(
        address token_,
        address tokenData_,
        address rolesContract,
        address[] initialWallets,
        uint256[] initialBalances)
    TokenLogic(token_, tokenData_, rolesContract) public
    {
        if (tokenData_ == address(0x0)) {
            uint256 totalSupply;
            require(initialBalances.length == initialWallets.length);
            for (uint256 i = 0; i < initialWallets.length; i++) {
                data.setBalances(initialWallets[i], initialBalances[i]);
                token.triggerTransfer(address(0x0), initialWallets[i], initialBalances[i]);
                totalSupply = Math.add(totalSupply, initialBalances[i]);
            }
            data.setSupply(totalSupply);
        }
    }
    function mintFor(address, uint256) public tokenOnly {
        assert(false);
    }
    function burn(address, uint256) public tokenOnly {
        assert(false);
    }
}
