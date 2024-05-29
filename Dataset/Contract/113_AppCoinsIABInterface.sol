contract AppCoinsIABInterface {
    function division(uint numerator, uint denominator) public view returns (uint);
    function buy(string _packageName, string _sku, uint256 _amount, address _addr_appc, address _dev, address _appstore, address _oem, bytes2 _countryCode) public view returns (bool);
}
