contract Mortal is Owned {
    function kill() onlyOwner
    { suicide(owner); }
}
