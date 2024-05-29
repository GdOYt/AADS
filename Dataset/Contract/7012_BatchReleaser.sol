contract BatchReleaser {
    function batchRelease(address[] vestingContracts, ERC20Basic token) external {
        for (uint256 i = 0; i < vestingContracts.length; i++) {
            VariableRateTokenVesting vesting = VariableRateTokenVesting(vestingContracts[i]);
            vesting.release(token);
        }
    }
}
