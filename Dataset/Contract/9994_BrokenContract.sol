contract BrokenContract is Pausable {
    address public newContractAddress;
    function setNewAddress(address _v2Address) external onlyOwner whenPaused {
        owner.transfer(address(this).balance);
        newContractAddress = _v2Address;
    }
}
