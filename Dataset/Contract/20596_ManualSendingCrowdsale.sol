contract ManualSendingCrowdsale is Owned {
    using SafeMath for uint256;
    struct AmountData {
        bool exists;
        uint256 value;
    }
    mapping (uint => AmountData) public amountsByCurrency;
    function addCurrency(uint currency) external onlyOwner {
        addCurrencyInternal(currency);
    }
    function addCurrencyInternal(uint currency) internal {
        AmountData storage amountData = amountsByCurrency[currency];
        amountData.exists = true;
    }
    function manualTransferTokensToInternal(address to, uint256 givenTokens, uint currency, uint256 amount) internal returns (uint256) {
        AmountData memory tempAmountData = amountsByCurrency[currency];
        require(tempAmountData.exists);
        AmountData storage amountData = amountsByCurrency[currency];
        amountData.value = amountData.value.add(amount);
        return transferTokensTo(to, givenTokens);
    }
    function transferTokensTo(address to, uint256 givenTokens) internal returns (uint256);
}
