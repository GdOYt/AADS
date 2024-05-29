contract OracleInterface {
    struct PriceData {
        uint ARTTokenPrice;
        uint blockHeight;
    }
    mapping(uint => PriceData) public historicPricing;
    uint public index;
    address public owner;
    uint8 public decimals;
    function setPrice(uint price) public returns (uint _index) {}
    function getPrice() public view returns (uint price, uint _index, uint blockHeight) {}
    function getHistoricalPrice(uint _index) public view returns (uint price, uint blockHeight) {}
    event Updated(uint indexed price, uint indexed index);
}
