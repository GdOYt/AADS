contract Restricted is Ownable {
    event MonethaAddressSet(
        address _address,
        bool _isMonethaAddress
    );
    mapping (address => bool) public isMonethaAddress;
    modifier onlyMonetha() {
        require(isMonethaAddress[msg.sender]);
        _;
    }
    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {
        isMonethaAddress[_address] = _isMonethaAddress;
        MonethaAddressSet(_address, _isMonethaAddress);
    }
}
