contract Contactable is Ownable {
  string public contactInformation;
  function setContactInformation(string info) onlyOwner public {
    contactInformation = info;
  }
}
