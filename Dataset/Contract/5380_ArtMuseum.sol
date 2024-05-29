contract ArtMuseum is ArtMuseumBase {
	address private _currentImplementation;
	function updateImplementation(address _newImplementation) onlyOwner public {
		require(_newImplementation != address(0));
		_currentImplementation = _newImplementation;
	}
	function implementation() public view returns (address) {
		return _currentImplementation;
	}
	function () payable public {
		address _impl = implementation();
		require(_impl != address(0));
		assembly {
			let ptr := mload(0x40)
			calldatacopy(ptr, 0, calldatasize)
			let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
			let size := returndatasize
			returndatacopy(ptr, 0, size)
			switch result
			case 0 { revert(ptr, size) }
			default { return(ptr, size) }
		}
	}
}
