contract Gateway is Owned {
  address public targetWallet;
  address public whitelistWallet;
  bool public gatewayOpened = false;
  mapping(address => bool) public whitelist;
  event TargetWalletUpdated(address _newWallet);
  event WhitelistWalletUpdated(address _newWhitelistWallet);
  event GatewayStatusUpdated(bool _status);
  event WhitelistUpdated(address indexed _participant, bool _status);
  event PassedGateway(address _participant, uint _value);
  constructor() public{
    targetWallet = owner;
    whitelistWallet = owner;
    newOwner = address(0x0);
  }
  function () payable public{
    passGateway();
  }
  function addToWhitelist(address _participant) external{
    require(msg.sender == whitelistWallet || msg.sender == owner);
    whitelist[_participant] = true;
    emit WhitelistUpdated(_participant, true);
  }  
  function addToWhitelistMultiple(address[] _participants) external{
    require(msg.sender == whitelistWallet || msg.sender == owner);
    for (uint i = 0; i < _participants.length; i++) {
      whitelist[_participants[i]] = true;
      emit WhitelistUpdated(_participants[i], true);
    }
  }
  function removeFromWhitelist(address _participant) external{
    require(msg.sender == whitelistWallet || msg.sender == owner);
    whitelist[_participant] = false;
    emit WhitelistUpdated(_participant, false);
  }  
  function removeFromWhitelistMultiple(address[] _participants) external{
    require(msg.sender == whitelistWallet || msg.sender == owner);
    for (uint i = 0; i < _participants.length; i++) {
      whitelist[_participants[i]] = false;
      emit WhitelistUpdated(_participants[i], false);
    }
  }
  function setTargetWallet(address _wallet) onlyOwner external{
    require(_wallet != address(0x0));
    targetWallet = _wallet;
    emit TargetWalletUpdated(_wallet);
  }
  function setWhitelistWallet(address _wallet) onlyOwner external{
    whitelistWallet = _wallet;
    emit WhitelistWalletUpdated(_wallet);
  }
  function openGateway() onlyOwner external{
    require(!gatewayOpened);
    gatewayOpened = true;
    emit GatewayStatusUpdated(true);
  }
  function closeGateway() onlyOwner external{
    require(gatewayOpened);
    gatewayOpened = false;
    emit GatewayStatusUpdated(false);
  }
  function passGateway() private{
    require(gatewayOpened);
    require(whitelist[msg.sender]);
    address(targetWallet).transfer(address(this).balance);
    emit PassedGateway(msg.sender, msg.value);
  }
  function transferAnyERC20Token(
    address tokenAddress,
    uint256 tokens
  )
    public
    onlyOwner
    returns (bool success)
  {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }
}
