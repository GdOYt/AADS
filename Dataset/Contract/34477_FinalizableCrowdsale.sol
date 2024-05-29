contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;
    bool public isFinalized = false;
    event Finalized();
    function FinalizableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token)
            Crowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
    }
    function finalize() onlyOwner {
        require(!isFinalized);
        require(hasEnded());
        isFinalized = true;
        finalization();
        Finalized();        
    }
    function finalization() internal {
    }
}
