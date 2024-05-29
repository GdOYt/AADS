contract CustomWhitelist is Ownable {
  mapping(address => bool) public whitelist;
  uint256 public numberOfWhitelists;
  event WhitelistedAddressAdded(address _addr);
  event WhitelistedAddressRemoved(address _addr);
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender] || msg.sender == owner);
    _;
  }
  constructor() public {
    whitelist[msg.sender] = true;
    numberOfWhitelists = 1;
    emit WhitelistedAddressAdded(msg.sender);
  }
  function addAddressToWhitelist(address _addr) onlyWhitelisted  public {
    require(_addr != address(0));
    require(!whitelist[_addr]);
    whitelist[_addr] = true;
    numberOfWhitelists++;
    emit WhitelistedAddressAdded(_addr);
  }
  function removeAddressFromWhitelist(address _addr) onlyWhitelisted  public {
    require(_addr != address(0));
    require(whitelist[_addr]);
    require(_addr != owner);
    whitelist[_addr] = false;
    numberOfWhitelists--;
    emit WhitelistedAddressRemoved(_addr);
  }
}
