contract Startable is Ownable, Authorizable {
  event Start();
  bool public started = false;
  modifier whenStarted() {
	require( started || authorized[msg.sender] );
    _;
  }
  function start() onlyOwner public {
    started = true;
    Start();
  }
}
