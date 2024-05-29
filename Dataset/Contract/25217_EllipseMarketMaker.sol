contract EllipseMarketMaker is TokenOwnable {
  uint256 public constant PRECISION = 10 ** 18;
  ERC20 public token1;
  ERC20 public token2;
  uint256 public R1;
  uint256 public R2;
  uint256 public S1;
  uint256 public S2;
  bool public operational;
  bool public openForPublic;
  address public mmLib;
  function EllipseMarketMaker(address _mmLib, address _token1, address _token2) public {
    require(_mmLib != address(0));
    bytes4 sig = 0x6dd23b5b;
    uint256 argsSize = 3 * 32;
    uint256 dataSize = 4 + argsSize;
    bytes memory m_data = new bytes(dataSize);
    assembly {
        mstore(add(m_data, 0x20), sig)
        mstore(add(m_data, 0x24), _mmLib)
        mstore(add(m_data, 0x44), _token1)
        mstore(add(m_data, 0x64), _token2)
    }
    require(_mmLib.delegatecall(m_data));
  }
  function supportsToken(address token) public constant returns (bool) {
    return (token1 == token || token2 == token);
  }
  function() public {
    address _mmLib = mmLib;
    if (msg.data.length > 0) {
      assembly {
        calldatacopy(0xff, 0, calldatasize)
        let retVal := delegatecall(gas, _mmLib, 0xff, calldatasize, 0, 0x20)
        switch retVal case 0 { revert(0,0) } default { return(0, 0x20) }
      }
    }
  }
}
