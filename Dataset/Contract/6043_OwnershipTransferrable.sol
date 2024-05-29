contract OwnershipTransferrable is TimeVaultToken {
    event OwnershipTransferred(address indexed _from, address indexed _to);
    function transferOwnership(address newOwner) onlyOwner public {
        transferByOwner(newOwner, balanceOf(owner), 0);
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
