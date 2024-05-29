contract PGOMonthlyPresaleVault is PGOMonthlyInternalVault {
    function vestedAmount(address beneficiary) public view returns (uint256) {
        uint256 vested = 0;
        if (block.timestamp >= start) {
            vested = investments[beneficiary].totalBalance.div(3);
        }
        if (block.timestamp >= cliff && block.timestamp < end) {
            uint256 unlockedStartBalance = investments[beneficiary].totalBalance.div(3);
            uint256 totalBalance = investments[beneficiary].totalBalance;
            uint256 lockedBalance = totalBalance.sub(unlockedStartBalance);
            uint256 monthlyBalance = lockedBalance.div(VESTING_DIV_RATE);
            uint256 daysToSkip = 90 days;
            uint256 time = block.timestamp.sub(start).sub(daysToSkip);
            uint256 elapsedOffsets = time.div(VESTING_INTERVAL);
            vested = vested.add(elapsedOffsets.mul(monthlyBalance));
        }
        if (block.timestamp >= end) {
            vested = investments[beneficiary].totalBalance;
        }
        return vested;
    }
}
