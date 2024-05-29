contract PGOVault {
    using SafeMath for uint256;
    using SafeERC20 for GotToken;
    uint256[4] public vesting_offsets = [
        360 days,
        540 days,
        720 days,
        900 days
    ];
    uint256[4] public vesting_amounts = [
        0.875e7 * 1e18,
        0.875e7 * 1e18,
        0.875e7 * 1e18,
        0.875e7 * 1e18
    ];
    address public pgoWallet;
    GotToken public token;
    uint256 public start;
    uint256 public released;
    uint256 public vestingOffsetsLength = vesting_offsets.length;
    constructor(
        address _pgoWallet,
        address _token,
        uint256 _start
    )
        public
    {
        pgoWallet = _pgoWallet;
        token = GotToken(_token);
        start = _start;
    }
    function release() public {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0);
        released = released.add(unreleased);
        token.safeTransfer(pgoWallet, unreleased);
    }
    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(released);
    }
    function vestedAmount() public view returns (uint256) {
        uint256 vested = 0;
        for (uint256 i = 0; i < vestingOffsetsLength; i = i.add(1)) {
            if (block.timestamp > start.add(vesting_offsets[i])) {
                vested = vested.add(vesting_amounts[i]);
            }
        }
        return vested;
    }
    function unreleasedAmount() public view returns (uint256) {
        uint256 unreleased = 0;
        for (uint256 i = 0; i < vestingOffsetsLength; i = i.add(1)) {
            unreleased = unreleased.add(vesting_amounts[i]);
        }
        return unreleased.sub(released);
    }
}
