contract NominAirdropper is Owned {
    constructor (address _owner) 
        Owned(_owner)
    {}
    function multisend(address tokenAddress, address[] destinations, uint256[] values)
        external
        onlyOwner
    {
        require(destinations.length == values.length);
        uint256 i = 0;
        while (i < destinations.length) {
            Nomin(tokenAddress).transferSenderPaysFee(destinations[i], values[i]);
            i += 1;
        }
    }
}
