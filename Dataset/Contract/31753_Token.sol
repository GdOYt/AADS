contract Token{
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function transfer(address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}