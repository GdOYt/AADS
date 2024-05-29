contract Oracle is Ownable {
    uint256 public constant VERSION = 3;
    event NewSymbol(bytes32 _currency, string _ticker);
    struct Symbol {
        string ticker;
        bool supported;
    }
    mapping(bytes32 => Symbol) public currencies;
    function url() public view returns (string);
    function getRate(bytes32 symbol, bytes data) public returns (uint256 rate, uint256 decimals);
    function addCurrency(string ticker) public onlyOwner returns (bytes32) {
        NewSymbol(currency, ticker);
        bytes32 currency = keccak256(ticker);
        currencies[currency] = Symbol(ticker, true);
        return currency;
    }
    function supported(bytes32 symbol) public view returns (bool) {
        return currencies[symbol].supported;
    }
}
