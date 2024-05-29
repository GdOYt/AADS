contract TokenTimelock {
    using SafeERC20 for ERC20Basic;
    ERC20Basic public token;
    address public beneficiary;
    uint64 public releaseTime;
    constructor(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
        require(_releaseTime > uint64(block.timestamp));
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }
    function release() public {
        require(uint64(block.timestamp) >= releaseTime);
        uint256 amount = token.balanceOf(this);
        require(amount > 0);
        token.safeTransfer(beneficiary, amount);
    }
}
