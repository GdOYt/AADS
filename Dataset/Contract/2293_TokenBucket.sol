contract TokenBucket is RBACMixin, IMintableToken {
  using SafeMath for uint;
  uint256 public size;
  uint256 public rate;
  uint256 public lastMintTime;
  uint256 public leftOnLastMint;
  IMintableToken public token;
  event Leak(address indexed to, uint256 left);
  constructor (address _token, uint256 _size, uint256 _rate) public {
    token = IMintableToken(_token);
    size = _size;
    rate = _rate;
    leftOnLastMint = _size;
  }
  function setSize(uint256 _size) public onlyOwner returns (bool) {
    size = _size;
    return true;
  }
  function setRate(uint256 _rate) public onlyOwner returns (bool) {
    rate = _rate;
    return true;
  }
  function setSizeAndRate(uint256 _size, uint256 _rate) public onlyOwner returns (bool) {
    return setSize(_size) && setRate(_rate);
  }
  function mint(address _to, uint256 _amount) public onlyMinter returns (bool) {
    uint256 available = availableTokens();
    require(_amount <= available);
    leftOnLastMint = available.sub(_amount);
    lastMintTime = now;  
    require(token.mint(_to, _amount));
    return true;
  }
  function availableTokens() public view returns (uint) {
    uint256 timeAfterMint = now.sub(lastMintTime);
    uint256 refillAmount = rate.mul(timeAfterMint).add(leftOnLastMint);
    return size < refillAmount ? size : refillAmount;
  }
}
