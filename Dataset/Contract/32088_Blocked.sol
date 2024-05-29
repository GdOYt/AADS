contract Blocked {
    uint public blockedUntil;
    modifier unblocked {
        require(now > blockedUntil);
        _;
    }
}
