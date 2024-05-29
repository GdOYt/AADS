contract KYCPayloadDeserializer {
  using BytesDeserializer for bytes;
  struct KYCPayload {
    address whitelistedAddress;  
    uint128 customerId;  
    uint32 minETH;  
    uint32 maxETH;  
    uint256 pricingInfo;
  }
  function getKYCPayload(bytes dataframe) public constant returns(address whitelistedAddress, uint128 customerId, uint32 minEth, uint32 maxEth, uint256 pricingInfo) {
    address _whitelistedAddress = dataframe.sliceAddress(0);
    uint128 _customerId = uint128(dataframe.slice16(20));
    uint32 _minETH = uint32(dataframe.slice4(36));
    uint32 _maxETH = uint32(dataframe.slice4(40));
    uint256 _pricingInfo = uint256(dataframe.slice32(44));
    return (_whitelistedAddress, _customerId, _minETH, _maxETH, _pricingInfo);
  }
}
