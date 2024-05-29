contract GrapevineWhitelistInterface {
  function whitelist(address _address) view external returns (bool);
  function handleOffchainWhitelisted(address _addr, bytes _sig) external returns (bool);
}
