contract Proxy {
  function implementation() public view returns (address);
  function () payable public {
    address impl = implementation();
    require(impl != address(0));
    bytes memory data = msg.data;
    assembly {
      let result := delegatecall(gas, impl, add(data, 0x20), mload(data), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)
    }
  }
}
