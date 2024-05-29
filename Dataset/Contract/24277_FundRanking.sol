contract FundRanking {
    function getAddressAndSharePriceOfFunds(address ofVersion)
        view
        returns(
            address[],
            uint[],
            uint[]
        )
    {
        Version version = Version(ofVersion);
        uint nofFunds = version.getLastFundId() + 1;
        address[] memory fundAddrs = new address[](nofFunds);
        uint[] memory sharePrices = new uint[](nofFunds);
        uint[] memory creationTimes = new uint[](nofFunds);
        for (uint i = 0; i < nofFunds; i++) {
            address fundAddress = version.getFundById(i);
            Fund fund = Fund(fundAddress);
            uint sharePrice = fund.calcSharePrice();
            uint creationTime = fund.getCreationTime();
            fundAddrs[i] = fundAddress;
            sharePrices[i] = sharePrice;
            creationTimes[i] = creationTime;
        }
        return (fundAddrs, sharePrices, creationTimes);
    }
}
