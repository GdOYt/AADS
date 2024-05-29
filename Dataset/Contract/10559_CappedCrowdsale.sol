contract CappedCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;
    uint256 public hardCap;
    uint256 public tokensToLock;
    uint256 public releaseTime;
    bool public isFinalized = false;
    TokenTimelock public timeLock;
    event Finalized();
    event FinishMinting();
    event TokensMinted(
        address indexed beneficiary,
        uint256 indexed amount
    );
    function CappedCrowdsale(uint256 _hardCap, uint256 _tokensToLock, uint256 _releaseTime) public {
        require(_hardCap > 0);
        require(_tokensToLock > 0);
        require(_releaseTime > endTime);
        hardCap = _hardCap;
        releaseTime = _releaseTime;
        tokensToLock = _tokensToLock;
        timeLock = new TokenTimelock(token, wallet, releaseTime);
    }
    function finalize() onlyOwner public {
        require(!isFinalized);
        token.mint(address(timeLock), tokensToLock);
        Finalized();
        isFinalized = true;
    }
    function finishMinting() onlyOwner public {
        require(token.mintingFinished() == false);
        require(isFinalized);
        token.finishMinting();
        FinishMinting();
    }
    function mint(address beneficiary, uint256 amount) onlyOwner public {
        require(!token.mintingFinished());
        require(isFinalized);
        require(amount > 0);
        require(beneficiary != address(0));
        token.mint(beneficiary, amount);
        TokensMinted(beneficiary, amount);
    }
    function hasEnded() public view returns (bool) {
        bool capReached = weiRaised >= hardCap;
        return super.hasEnded() || capReached || isFinalized;
    }
}
