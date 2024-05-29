contract VestingTrustee is Ownable, CanReclaimToken {
    using SafeMath for uint256;
    ERC20 public token;
    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 installmentLength;  
        uint256 transferred;
        bool revokable;
        uint256 prevested;
        uint256 vestingPercentage;
    }
    mapping (address => Grant) public grants;
    uint256 public totalVesting;
    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event TokensUnlocked(address indexed _to, uint256 _value);
    event GrantRevoked(address indexed _holder, uint256 _refund);
    function VestingTrustee(address _token) {
        require(_token != address(0));
        token = ERC20(_token);
    }
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end,
        uint256 _installmentLength, uint256 vestingPercentage, uint256 prevested, bool _revokable)
        external onlyOwner {
        require(_to != address(0));
        require(_to != address(this));  
        require(_value > 0);
        require(_value.sub(prevested) > 0);
        require(vestingPercentage > 0);
        require(grants[_to].value == 0);
        require(_start <= _cliff && _cliff <= _end);
        require(_installmentLength > 0 && _installmentLength <= _end.sub(_start));
        require(totalVesting.add(_value.sub(prevested)) <= token.balanceOf(address(this)));
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            installmentLength: _installmentLength,
            transferred: prevested,
            revokable: _revokable,
            prevested: prevested,
            vestingPercentage: vestingPercentage
        });
        totalVesting = totalVesting.add(_value.sub(prevested));
        NewGrant(msg.sender, _to, _value);
    }
    function revoke(address _holder) public onlyOwner {
        Grant memory grant = grants[_holder];
        require(grant.revokable);
        uint256 refund = grant.value.sub(grant.transferred);
        delete grants[_holder];
        totalVesting = totalVesting.sub(refund);
        token.transfer(msg.sender, refund);
        GrantRevoked(_holder, refund);
    }
    function vestedTokens(address _holder, uint256 _time) external constant returns (uint256) {
        Grant memory grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }
        return calculateVestedTokens(grant, _time);
    }
    function calculateVestedTokens(Grant _grant, uint256 _time) private constant returns (uint256) {
        if (_time < _grant.cliff) {
            return _grant.prevested;
        }
        if (_time >= _grant.end) {
            return _grant.value;
        }
        uint256 installmentsPast = _time.sub(_grant.cliff).div(_grant.installmentLength) + 1;
        return _grant.prevested.add(_grant.value.mul(installmentsPast.mul(_grant.vestingPercentage)).div(100));
    }
    function unlockVestedTokens() external {
        Grant storage grant = grants[msg.sender];
        require(grant.value != 0);
        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            revert();
        }
        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            revert();
        }
        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        token.transfer(msg.sender, transferable);
        TokensUnlocked(msg.sender, transferable);
    }
    function reclaimEther() external onlyOwner {
      assert(owner.send(this.balance));
    }
}
