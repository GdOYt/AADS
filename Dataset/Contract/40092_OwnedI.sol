contract OwnedI {
    event LogOwnerChanged(address indexed previousOwner, address indexed newOwner);
    function getOwner()
        constant
        returns (address);
    function setOwner(address newOwner)
        returns (bool success); 
}
