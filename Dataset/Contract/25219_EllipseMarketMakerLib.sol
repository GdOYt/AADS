contract EllipseMarketMakerLib is TokenOwnable, IEllipseMarketMaker {
  using SafeMath for uint256;
  uint256 private l_R1;
  uint256 private l_R2;
  modifier notConstructed() {
    require(mmLib == address(0));
    _;
  }
  modifier isOperational() {
    require(operational);
    _;
  }
  modifier notOperational() {
    require(!operational);
    _;
  }
  modifier canTrade() {
    require(openForPublic || msg.sender == owner);
    _;
  }
  modifier canTrade223() {
    require (openForPublic || tkn.sender == owner);
    _;
  }
  function constructor(address _mmLib, address _token1, address _token2) public onlyOwner notConstructed returns (bool) {
    require(_mmLib != address(0));
    require(_token1 != address(0));
    require(_token2 != address(0));
    require(_token1 != _token2);
    mmLib = _mmLib;
    token1 = ERC20(_token1);
    token2 = ERC20(_token2);
    R1 = 0;
    R2 = 0;
    S1 = token1.totalSupply();
    S2 = token2.totalSupply();
    operational = false;
    openForPublic = false;
    return true;
  }
  function openForPublicTrade() public onlyOwner isOperational returns (bool) {
    openForPublic = true;
    return true;
  }
  function isOpenForPublic() public onlyOwner returns (bool) {
    return (openForPublic && operational);
  }
  function supportsToken(address _token) public constant returns (bool) {
      return (token1 == _token || token2 == _token);
  }
  function initializeAfterTransfer() public notOperational onlyOwner returns (bool) {
    require(initialize());
    return true;
  }
  function initializeOnTransfer() public notOperational onlyTokenOwner tokenPayable returns (bool) {
    require(initialize());
    return true;
  }
  function initialize() private returns (bool success) {
    R1 = token1.balanceOf(this);
    R2 = token2.balanceOf(this);
    success = ((R1 == 0 && R2 == S2) || (R2 == 0 && R1 == S1));
    if (success) {
      operational = true;
    }
  }
  function getCurrentPrice() public constant isOperational returns (uint256) {
    return getPrice(R1, R2, S1, S2);
  }
  function getPrice(uint256 _R1, uint256 _R2, uint256 _S1, uint256 _S2) public constant returns (uint256 price) {
    price = PRECISION;
    price = price.mul(_S1.sub(_R1));
    price = price.div(_S2.sub(_R2));
    price = price.mul(_S2);
    price = price.div(_S1);
    price = price.mul(_S2);
    price = price.div(_S1);
  }
  function quoteAndReserves(address _fromToken, uint256 _inAmount, address _toToken) private isOperational returns (uint256 returnAmount) {
    if (token1 == _fromToken && token2 == _toToken) {
      l_R1 = R1.add(_inAmount);
      l_R2 = calcReserve(l_R1, S1, S2);
      if (l_R2 > R2) {
        return 0;
      }
      returnAmount = R2.sub(l_R2);
    }
    else if (token2 == _fromToken && token1 == _toToken) {
      l_R2 = R2.add(_inAmount);
      l_R1 = calcReserve(l_R2, S2, S1);
      if (l_R1 > R1) {
        return 0;
      }
      returnAmount = R1.sub(l_R1);
    } else {
      return 0;
    }
  }
  function quote(address _fromToken, uint256 _inAmount, address _toToken) public constant isOperational returns (uint256 returnAmount) {
    uint256 _R1;
    uint256 _R2;
    if (token1 == _fromToken && token2 == _toToken) {
      _R1 = R1.add(_inAmount);
      _R2 = calcReserve(_R1, S1, S2);
      if (_R2 > R2) {
        return 0;
      }
      returnAmount = R2.sub(_R2);
    }
    else if (token2 == _fromToken && token1 == _toToken) {
      _R2 = R2.add(_inAmount);
      _R1 = calcReserve(_R2, S2, S1);
      if (_R1 > R1) {
        return 0;
      }
      returnAmount = R1.sub(_R1);
    } else {
      return 0;
    }
  }
  function calcReserve(uint256 _R1, uint256 _S1, uint256 _S2) public pure returns (uint256 _R2) {
    _R2 = _S2
      .mul(
        _S1
        .sub(
          _R1
          .mul(_S1)
          .mul(2)
          .sub(
            _R1
            .toPower2()
          )
          .sqrt()
        )
      )
      .div(_S1);
  }
  function change(address _fromToken, uint256 _inAmount, address _toToken) public canTrade returns (uint256 returnAmount) {
    return change(_fromToken, _inAmount, _toToken, 0);
  }
  function change(address _fromToken, uint256 _inAmount, address _toToken, uint256 _minReturn) public canTrade returns (uint256 returnAmount) {
    require(ERC20(_fromToken).transferFrom(msg.sender, this, _inAmount));
    returnAmount = exchange(_fromToken, _inAmount, _toToken, _minReturn);
    if (returnAmount == 0) {
      revert();
    }
    ERC20(_toToken).transfer(msg.sender, returnAmount);
    require(validateReserves());
    Change(_fromToken, _inAmount, _toToken, returnAmount, msg.sender);
  }
  function change(address _toToken) public canTrade223 tokenPayable returns (uint256 returnAmount) {
    return change(_toToken, 0);
  }
  function change(address _toToken, uint256 _minReturn) public canTrade223 tokenPayable returns (uint256 returnAmount) {
    address fromToken = tkn.addr;
    uint256 inAmount = tkn.value;
    returnAmount = exchange(fromToken, inAmount, _toToken, _minReturn);
    if (returnAmount == 0) {
      revert();
    }
    ERC20(_toToken).transfer(tkn.sender, returnAmount);
    require(validateReserves());
    Change(fromToken, inAmount, _toToken, returnAmount, tkn.sender);
  }
  function exchange(address _fromToken, uint256 _inAmount, address _toToken, uint256 _minReturn) private returns (uint256 returnAmount) {
    returnAmount = quoteAndReserves(_fromToken, _inAmount, _toToken);
    if (returnAmount == 0 || returnAmount < _minReturn) {
      return 0;
    }
    updateReserve();
  }
  function updateReserve() private {
    R1 = l_R1;
    R2 = l_R2;
  }
  function validateReserves() public view returns (bool) {
    return (token1.balanceOf(this) >= R1 && token2.balanceOf(this) >= R2);
  }
  function withdrawExcessReserves() public onlyOwner returns (uint256 returnAmount) {
    if (token1.balanceOf(this) > R1) {
      returnAmount = returnAmount.add(token1.balanceOf(this).sub(R1));
      token1.transfer(msg.sender, token1.balanceOf(this).sub(R1));
    }
    if (token2.balanceOf(this) > R2) {
      returnAmount = returnAmount.add(token2.balanceOf(this).sub(R2));
      token2.transfer(msg.sender, token2.balanceOf(this).sub(R2));
    }
  }
}
