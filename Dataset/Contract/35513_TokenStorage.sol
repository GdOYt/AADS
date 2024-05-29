contract TokenStorage{
  function name() constant returns (string _name) {}
  function symbol() constant returns (string _symbol) {}
  function decimals() constant returns (uint8 _decimals) {}
  function totalSupply() constant returns (uint48 _totalSupply)  {}
  function transfer(address _to, uint48 _value, bytes _data, string _custom_fallback) returns (bool success) {}
  function transfer(address _to, uint48 _value, bytes _data) returns (bool success) {}
  function transfer(address _to, uint48 _value) returns (bool success) {}
  function isContract(address _addr) private returns (bool is_contract) {}
  function transferToAddress(address _to, uint48 _value, bytes _data) private returns (bool success)  {}
  function transferToContract(address _to, uint48 _value, bytes _data) private returns (bool success)  {}
  function balanceOf(address _owner) constant returns (uint48 balance) {}
}
