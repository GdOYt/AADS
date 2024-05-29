contract BdpBaseData {
	address public ownerAddress;
	address public managerAddress;
	address[16] public contracts;
	bool public paused = false;
	bool public setupCompleted = false;
	bytes8 public version;
}
