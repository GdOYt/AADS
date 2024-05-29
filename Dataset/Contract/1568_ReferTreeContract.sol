contract ReferTreeContract is Ownable {
    mapping(address => address) public referTree;
    event TreeStructChanged(address sender, address parentSender);
    function checkTreeStructure(address sender, address parentSender) onlyOwner public {
        setTreeStructure(sender, parentSender);
    }
    function setTreeStructure(address sender, address parentSender) internal {
        require(referTree[sender] == 0x0);
        require(sender != parentSender);
        referTree[sender] = parentSender;
        TreeStructChanged(sender, parentSender);
    }
}
