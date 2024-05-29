contract PriceReceiver {
  address public ethPriceProvider;
  modifier onlyEthPriceProvider() {
    require(msg.sender == ethPriceProvider);
    _;
  }
  function receiveEthPrice(uint ethUsdPrice) external;
  function setEthPriceProvider(address provider) external;
}
