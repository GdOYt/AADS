contract AcceptsProofofHumanity {
    ProofofHumanity public tokenContract;
    constructor(address _tokenContract) public {
        tokenContract = ProofofHumanity(_tokenContract);
    }
    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}
