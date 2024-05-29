contract Whitelist {
    address public whitelister;
    mapping (address => bool) whitelist;
    constructor() public {
        whitelister = msg.sender;
    }
    modifier onlyWhitelister() {
        require(msg.sender == whitelister);
        _;
    }
    function addToWhitelist(address _address) public onlyWhitelister {
        require(_address != address(0));
        emit WhitelistAdd(whitelister, _address);
        whitelist[_address] = true;
    }
    function removeFromWhitelist(address _address) public onlyWhitelister {
        require(_address != address(0));
        emit WhitelistRemove(whitelister, _address);
        whitelist[_address] = false;
    }
    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }
    function changeWhitelister(address _newWhitelister) public onlyWhitelister {
        require(_newWhitelister != address(0));
        emit WhitelisterChanged(whitelister, _newWhitelister);
        whitelister = _newWhitelister;
    }
    event WhitelisterChanged(address indexed previousWhitelister, address indexed newWhitelister);
    event WhitelistAdd(address indexed whitelister, address indexed whitelistedAddress);
    event WhitelistRemove(address indexed whitelister, address indexed whitelistedAddress); 
}
