contract SafeMath {
  function add(uint256 x, uint256 y) pure internal returns (uint256) {
    require(x <= x + y);
    return x + y;
  }
  function sub(uint256 x, uint256 y) pure internal returns (uint256) {
    require(x >= y);
    return x - y;
  }
}
