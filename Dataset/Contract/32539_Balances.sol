contract Balances is CanTransferTokens, SafeMath, useContractWeb {
  mapping(address => uint256) internal _balances;
  function get(address _account) view public returns (uint256) {
    return _balances[_account];
  }
  function tokenContract() view internal returns (address) {
    return web.getContractAddress("Token");
  }
  function Balances() public {
    _balances[msg.sender] = 190 * 1000000 * 1000000000000000000;
  }
  modifier onlyToken {
    require(msg.sender == tokenContract());
    _;
  }
  function transfer(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) onlyToken public returns (bool success) {
  _balances[_from] = sub(_balances[_from], _value);
  _balances[_to] = add(_balances[_to], _value);
  return true;
  }
}
