contract Router is ThisMustBeFirst, AuthorizedList, CodeTricks, Authorized {
  function Router(address _token_address, address _storage_address) public Authorized() {
     require(_token_address != address(0));
     require(_storage_address != address(0));
     token_address = _token_address;
     bts_address1 = _storage_address;
  }
  function nameSuccessor(address _token_address) public ifAuthorized(msg.sender, I_AM_ROOT) {
     require(_token_address != address(0));
     token_address = _token_address;
  }
  function setStorage(address _storage_address) public ifAuthorized(msg.sender, I_AM_ROOT) {
     require(_storage_address != address(0));
     bts_address1 = _storage_address;
  }
  function setSecondaryStorage(address _storage_address) public ifAuthorized(msg.sender, I_AM_ROOT) {
     require(_storage_address != address(0));
     bts_address2 = _storage_address;
  }
  function swapStorage() public ifAuthorized(msg.sender, I_AM_ROOT) {
     address temp = bts_address1;
     bts_address1 = bts_address2;
     bts_address2 = temp;
  }
  function() public payable {
      var target = token_address;
      assembly {
          let _calldata := mload(0x40)
          mstore(0x40, add(_calldata, calldatasize))
          calldatacopy(_calldata, 0x0, calldatasize)
          switch delegatecall(gas, target, _calldata, calldatasize, 0, 0)
            case 0 { revert(0, 0) }
            default {
              let _returndata := mload(0x40)
              returndatacopy(_returndata, 0, returndatasize)
              mstore(0x40, add(_returndata, returndatasize))
              return(_returndata, returndatasize)
            }
       }
   }
}
