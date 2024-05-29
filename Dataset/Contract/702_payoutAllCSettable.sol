contract payoutAllCSettable is payoutAllC {
    constructor (address initPayTo) payoutAllC(initPayTo) public {
    }
    function setPayTo(address) external;
    function getPayTo() external view returns (address) {
        return _getPayTo();
    }
}
