contract ZethrInterface {
  function balanceOf(address who) public view returns (uint);
  function transfer(address _to, uint _value) public returns (bool);
	function withdraw(address _recipient) public;
}
