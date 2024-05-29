contract FailingERC223Receiver is ERC223Receiver {
    function tokenFallback(address, uint, bytes) public {
        revert();
    }
}
