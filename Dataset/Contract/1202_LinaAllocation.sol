contract LinaAllocation is Ownable {
    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;
    address[] public vestings;
    event VestingCreated(
        address _vesting,
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable
    );
    event VestingRevoked(address _vesting);
    function LinaAllocation(
        address _beneficiary,
        uint256 _startingAt
    ) public {
        require(_beneficiary != address(0) && _startingAt > 0);
        initVesting(_beneficiary, _startingAt);
    }
    function initVesting(
        address _beneficiary,
        uint256 _startingAt
    ) public onlyOwner {
        createVesting(
            _beneficiary,
            _startingAt,
            0,
            2629746,
            120,
            true,
            msg.sender
        );
    }
    function createVesting(
        address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _periods, bool _revocable, address _unreleasedHolder
    ) public onlyOwner returns (PeriodicTokenVesting) {
        PeriodicTokenVesting vesting = new PeriodicTokenVesting(
            _beneficiary, _start, _cliff, _duration, _periods, _revocable, _unreleasedHolder
        );
        vestings.push(vesting);
        VestingCreated(vesting, _beneficiary, _start, _cliff, _duration, _periods, _revocable);
        return vesting;
    }
    function revokeVesting(PeriodicTokenVesting _vesting, ERC20Basic token) public onlyOwner() {
        _vesting.revoke(token);
        VestingRevoked(_vesting);
    }
}
