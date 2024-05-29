contract Cosigner {
    uint256 public constant VERSION = 2;
    function url() public view returns (string);
    function cost(address engine, uint256 index, bytes data, bytes oracleData) public view returns (uint256);
    function requestCosign(Engine engine, uint256 index, bytes data, bytes oracleData) public returns (bool);
    function claim(address engine, uint256 index, bytes oracleData) public returns (bool);
}
