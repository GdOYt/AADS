contract SeriesFactory {
    address public seriesFactory;
    address public owner;
    function createSeries (
        uint seriesId,
        bytes name,
        uint shares,
        string industry,
        string symbol,
        address manager,
        address extraContract
    ) payable returns (
        address addr,
        bytes32 newName
    ) {
        address newSeries;
        bytes32 _newName;
        return (newSeries, _newName);
    }
}
