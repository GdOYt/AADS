contract BdpBaseData {
	address public ownerAddress;
	address public managerAddress;
	address[16] public contracts;
	bool public paused = false;
	bool public setupComplete = false;
	bytes8 public version;
}
