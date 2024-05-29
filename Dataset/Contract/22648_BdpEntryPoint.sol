contract BdpEntryPoint is BdpBaseData {
	function () payable public {
		address _impl = BdpContracts.getBdpController(contracts);
		require(_impl != address(0));
		bytes memory data = msg.data;
		assembly {
			let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
			let size := returndatasize
			let ptr := mload(0x40)
			returndatacopy(ptr, 0, size)
			switch result
			case 0 { revert(ptr, size) }
			default { return(ptr, size) }
		}
	}
	function BdpEntryPoint(address[16] _contracts, bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		contracts = _contracts;
		setupComplete = true;
		version = _version;
	}
}
