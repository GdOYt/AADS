contract IERC20Token {
    function totalSupply() public constant returns ( uint256 supply ) { supply; }
    function balanceOf( address _owner ) public constant returns ( uint256 balance ) { _owner; balance; }
    function allowance( address _owner, address _spender ) public constant returns ( uint256 remaining ) { _owner; _spender; remaining; }
  function transfer( address _to, uint256 _value ) public returns ( bool success );
  function transferFrom( address _from, address _to, uint256 _value ) public returns ( bool success );
  function approve( address _spender, uint256 _value ) public returns ( bool success );
}
