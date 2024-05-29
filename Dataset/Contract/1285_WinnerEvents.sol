contract WinnerEvents {
    event onBuy
    (
        address paddr,
        uint256 ethIn,
        string  reff,
        uint256 timeStamp
    );
    event onBuyUseBalance
    (
        address paddr,
        uint256 keys,
        uint256 timeStamp
    );
    event onBuyName
    (
        address paddr,
        bytes32 pname,
        uint256 ethIn,
        uint256 timeStamp
    );
    event onWithdraw
    (
        address paddr,
        uint256 ethOut,
        uint256 timeStamp
    );
    event onUpRoundID
    (
        uint256 roundID
    );
    event onUpPlayer
    (
        address addr,
        bytes32 pname,
        uint256 balance,
        uint256 interest,
        uint256 win,
        uint256 reff
    );
    event onAddPlayerOrder
    (
        address addr,
        uint256 keys,
        uint256 eth,
        uint256 otype
    );
    event onUpPlayerRound
    (
        address addr,
        uint256 roundID,
        uint256 eth,
        uint256 keys,
        uint256 interest,
        uint256 win,
        uint256 reff
    );
    event onUpRound
    (
        uint256 roundID,
        address leader,
        uint256 start,
        uint256 end,
        bool ended,
        uint256 keys,
        uint256 eth,
        uint256 pool,
        uint256 interest,
        uint256 win,
        uint256 reff
    );
}
