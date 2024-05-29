contract SolutionGame is HWCIntegration {
    uint256 countWinnerPlace;
    mapping (uint256 => uint256) internal prizeDistribution;
    mapping (uint256 => uint256) internal prizesByPlace;
    mapping (uint256 => uint256) internal scoreByPlace;
    mapping (uint => uint) winnerMap;
    uint[] winnerList;
    mapping (uint256 => uint256) internal prizesByPlaceHWC;
    bool isWinnerTime = false;
    modifier whenWinnerTime() {
        require(isWinnerTime);
        _;
    }
    constructor(string _name, string _symbol) HWCIntegration(_name, _symbol) public {
        countWinnerPlace = 0;       
    }
    function() external payable {
        _addToFund(msg.value, true);
    }
    function setWinnerTimeStatus(bool _status) external onlyOwner {
        isWinnerTime = _status;
    }
    function withdrawBalance() external onlyOwner {
        owner.transfer(address(this).balance.sub(prizeFund));
    }
    function setCountWinnerPlace(uint256 _val) external onlyOwner {
        countWinnerPlace = _val;
    }
    function setWinnerPlaceDistribution(uint256 place, uint256 _val) external onlyOwner {
        require(place <= countWinnerPlace);
        require(_val <= 10000);
        uint256 testVal = 0;
        uint256 index;
        for (index = 1; index <= countWinnerPlace; index ++) {
            if(index != place) {
                testVal = testVal + prizeDistribution[index];
            }
        }
        testVal = testVal + _val;
        require(testVal <= 10000);
        prizeDistribution[place] = _val;
    }
    function setCountWinnerByPlace(uint256 place, uint256 _winnerCount, uint256 _winnerScore) public onlyOwner whenPaused {
        require(_winnerCount > 0);
        require(place <= countWinnerPlace);
        prizesByPlace[place] = prizeFund.mul(prizeDistribution[place]).div(10000).div(_winnerCount);
        prizesByPlaceHWC[place] = prizeFundHWC.mul(prizeDistribution[place]).div(10000).div(_winnerCount);
        scoreByPlace[place] = _winnerScore;
    }
    function checkIsWinner(uint _tokenId) public view whenPaused onlyOwnerOf(_tokenId)
    returns (uint place) {
        place = 0;
        uint score = getScore(_tokenId);
        for(uint index = 1; index <= countWinnerPlace; index ++) {
            if (score == scoreByPlace[index]) {
                place = index;
                break;
            }
        }
    }
    function getMyPrize() external whenWinnerTime {
        uint[] memory tokenList = tokensOfOwner(msg.sender);
        for(uint index = 0; index < tokenList.length; index ++) {
            getPrizeByToken(tokenList[index]);
        }
    }
    function getPrizeByToken(uint _tokenId) public whenWinnerTime onlyOwnerOf(_tokenId) {
        uint place = checkIsWinner(_tokenId);
        require (place > 0);
        uint prize = prizesByPlace[place];
        if(prize > 0) {
            if(winnerMap[_tokenId] == 0) {
                winnerMap[_tokenId] = prize;
                winnerList.push(_tokenId);
                address _owner = tokenOwner[_tokenId];
                if(_owner != address(0)){
                    uint hwcPrize = prizesByPlaceHWC[place];
                    hwcAddress[_owner].deposit = hwcAddress[_owner].deposit + hwcPrize;
                    _owner.transfer(prize);
                }
            }
        }
    }
    function getWinnerList() external view onlyAdmin returns (uint[]) {
        return winnerList;
    }
    function getWinnerInfo(uint _tokenId) external view onlyAdmin returns (uint){
        return winnerMap[_tokenId];
    }
    function getResultTable(uint _start, uint _count) external view returns (uint[]) {
        uint[] memory results = new uint[](_count);
        for(uint index = _start; index < tokens.length && index < (_start + _count); index++) {
            results[(index - _start)] = getScore(index);
        }
        return results;
    }
}
