contract EscapeMmmEvents {
    event onOffered (
        address indexed playerAddress,
        uint256 offerAmount,
        address affiliateAddress,
        address siteOwner,
        uint256 timestamp
    );
    event onAccepted (
        address indexed playerAddress,
        uint256 acceptAmount
    );
    event onWithdraw (
        address indexed playerAddress,
        uint256 withdrawAmount
    );
    event onAirDrop (
        address indexed playerAddress,
        uint256 airdropAmount,
        uint256 offerAmount
    );
}
