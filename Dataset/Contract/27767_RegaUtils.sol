contract RegaUtils {
  modifier validAddress( address _address ) {
    require( _address != 0x0 );
    _;
  }
  function safeAdd( uint256 x, uint256 y ) internal returns( uint256 ) {
    uint256 z = x + y;
    assert( z >= x );
    return z;
  }
  function safeSub( uint256 x, uint256 y ) internal returns( uint256 ) {
    assert( x >= y);
    return x - y;
  }
}
