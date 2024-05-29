contract AcceptsElyxr {
    Elyxr public tokenContract;
    function AcceptsElyxr(address _tokenContract) public {
        tokenContract = Elyxr(_tokenContract);
    }
    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}
