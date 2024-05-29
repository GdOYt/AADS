contract Controller {
	address public owner;
	modifier onlyOwner {
    	require(msg.sender == owner);
    	_;
  	}
  	function change_owner(address new_owner) onlyOwner {
    	require(new_owner != 0x0);
    	owner = new_owner;
  	}
  	function Controller() {
    	owner = msg.sender;
  	}
}
