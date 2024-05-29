contract BaseGameLogic is BaseGame {
    uint public prizeFund = 0;
    uint public basePrice = 21 finney;
    uint public gameCloneFee = 7000;          
    uint public priceFactor = 10000;          
    uint public prizeFundFactor = 5000;       
    constructor(string _name, string _symbol) BaseGame(_name, _symbol) public {}
    function _addToFund(uint _val, bool isAll) internal whenNotPaused {
        if(isAll) {
            prizeFund = prizeFund.add(_val);
        } else {
            prizeFund = prizeFund.add(_val.mul(prizeFundFactor).div(10000));
        }
    }
    function createAccount() external payable whenNotPaused returns (uint) {
        require(msg.value >= basePrice);
        _addToFund(msg.value, false);
        return _createToken(0, msg.sender);
    }
    function cloneAccount(uint _tokenId) external payable whenNotPaused returns (uint) {
        require(exists(_tokenId));
        uint tokenPrice = calculateTokenPrice(_tokenId);
        require(msg.value >= tokenPrice);
        uint newToken = _createToken( _tokenId, msg.sender);
        uint gameFee = tokenPrice.mul(gameCloneFee).div(10000);
        _addToFund(gameFee, false);
        uint ownerProceed = tokenPrice.sub(gameFee);
        address tokenOwnerAddress = tokenOwner[_tokenId];
        tokenOwnerAddress.transfer(ownerProceed);
        return newToken;
    }
    function createForecast(uint _tokenId, uint _gameId,
        uint8 _goalA, uint8 _goalB, bool _odds, uint8 _shotA, uint8 _shotB)
    external whenNotPaused onlyOwnerOf(_tokenId) returns (uint){
        require(exists(_tokenId));
        require(block.timestamp < games[_gameId].gameDate);
        uint _forecastData = toForecastData(_goalA, _goalB, _odds, _shotA, _shotB);
        return _createForecast(_tokenId, _gameId, _forecastData);
    }
    function tokensOfOwner(address _owner) public view returns(uint[] ownerTokens) {
        uint tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint[](0);
        } else {
            uint[] memory result = new uint[](tokenCount);
            uint totalToken = totalSupply();
            uint resultIndex = 0;
            uint _tokenId;
            for (_tokenId = 1; _tokenId <= totalToken; _tokenId++) {
                if (tokenOwner[_tokenId] == _owner) {
                    result[resultIndex] = _tokenId;
                    resultIndex++;
                }
            }
            return result;
        }
    }
    function forecastOfToken(uint _tokenId) public view returns(uint[]) {
        uint forecastCount = tokenForecasts[_tokenId].length;
        if (forecastCount == 0) {
            return new uint[](0);
        } else {
            uint[] memory result = new uint[](forecastCount);
            uint resultIndex;
            for (resultIndex = 0; resultIndex < forecastCount; resultIndex++) {
                result[resultIndex] = tokenForecasts[_tokenId][resultIndex];
            }
            return result;
        }
    }
    function gameInfo(uint _gameId) external view returns(
        uint64 gameDate, Teams teamA, Teams teamB, uint goalA, uint gaolB,
        bool odds, uint shotA, uint shotB, uint forecastCount
    ){
        gameDate = games[_gameId].gameDate;
        teamA = games[_gameId].teamA;
        teamB = games[_gameId].teamB;
        goalA = games[_gameId].goalA;
        gaolB = games[_gameId].goalB;
        odds = games[_gameId].odds;
        shotA = games[_gameId].shotA;
        shotB = games[_gameId].shotB;
        forecastCount = games[_gameId].forecasts.length;
    }
    function forecastInfo(uint _fId) external view
        returns(uint gameId, uint f) {
        gameId = forecasts[_fId].gameId;
        f = forecasts[_fId].forecastData;
    }
    function tokenInfo(uint _tokenId) external view
        returns(uint createBlockNumber, uint parentId, uint forecast, uint score, uint price) {
        createBlockNumber = tokens[_tokenId].createBlockNumber;
        parentId = tokens[_tokenId].parentId;
        price = calculateTokenPrice(_tokenId);
        forecast = getForecastCount(_tokenId, block.number, false);
        score = getScore(_tokenId);
    }
    function calculateTokenPrice(uint _tokenId) public view returns(uint) {
        require(exists(_tokenId));
        uint forecastCount = getForecastCount(_tokenId, block.number, true);
        return (forecastCount.add(1)).mul(basePrice).mul(priceFactor).div(10000);
    }
    function getForecastCount(uint _tokenId, uint _blockNumber, bool isReleased) public view returns(uint) {
        require(exists(_tokenId));
        uint forecastCount = 0 ;
        uint index = 0;
        uint count = tokenForecasts[_tokenId].length;
        for (index = 0; index < count; index++) {
            if(forecasts[tokenForecasts[_tokenId][index]].forecastBlockNumber < _blockNumber){
                if(isReleased) {
                    if (games[forecasts[tokenForecasts[_tokenId][index]].gameId].gameDate < block.timestamp) {
                        forecastCount = forecastCount + 1;
                    }
                } else {
                    forecastCount = forecastCount + 1;
                }
            }
        }
        if(tokens[_tokenId].parentId != 0){
            forecastCount = forecastCount.add(getForecastCount(tokens[_tokenId].parentId,
                tokens[_tokenId].createBlockNumber, isReleased));
        }
        return forecastCount;
    }
    function getScore(uint _tokenId) public view returns (uint){
        uint[] memory _gameForecast = new uint[](65);
        return getScore(_tokenId, block.number, _gameForecast);
    }
    function getScore(uint _tokenId, uint _blockNumber, uint[] _gameForecast) public view returns (uint){
        uint score = 0;
        uint[] memory _forecasts = forecastOfToken(_tokenId);
        if (_forecasts.length > 0){
            uint256 _index;
            for(_index = _forecasts.length - 1; _index >= 0 && _index < _forecasts.length ; _index--){
                if(forecasts[_forecasts[_index]].forecastBlockNumber < _blockNumber &&
                    _gameForecast[forecasts[_forecasts[_index]].gameId] == 0 &&
                    block.timestamp > games[forecasts[_forecasts[_index]].gameId].gameDate
                ){
                    score = score.add(calculateScore(
                            forecasts[_forecasts[_index]].gameId,
                            forecasts[_forecasts[_index]].forecastData
                        ));
                    _gameForecast[forecasts[_forecasts[_index]].gameId] = forecasts[_forecasts[_index]].forecastBlockNumber;
                }
            }
        }
        if(tokens[_tokenId].parentId != 0){
            score = score.add(getScore(tokens[_tokenId].parentId, tokens[_tokenId].createBlockNumber, _gameForecast));
        }
        return score;
    }
    function getForecastScore(uint256 _forecastId) external view returns (uint256) {
        require(_forecastId < forecasts.length);
        return calculateScore(
            forecasts[_forecastId].gameId,
            forecasts[_forecastId].forecastData
        );
    }
    function calculateScore(uint256 _gameId, uint d)
    public view returns (uint256){
        require(block.timestamp > games[_gameId].gameDate);
        uint256 _shotB = (d & 0xff);
        d = d >> 8;
        uint256 _shotA = (d & 0xff);
        d = d >> 8;
        uint odds8 = (d & 0xff);
        bool _odds = odds8 == 1 ? true: false;
        d = d >> 8;
        uint256 _goalB = (d & 0xff);
        d = d >> 8;
        uint256 _goalA = (d & 0xff);
        d = d >> 8;
        Game memory cGame = games[_gameId];
        uint256 _score = 0;
        bool isDoubleScore = true;
        if(cGame.shotA == _shotA) {
            _score = _score.add(1);
        } else {
            isDoubleScore = false;
        }
        if(cGame.shotB == _shotB) {
            _score = _score.add(1);
        } else {
            isDoubleScore = false;
        }
        if(cGame.odds == _odds) {
            _score = _score.add(1);
        } else {
            isDoubleScore = false;
        }
        if((cGame.goalA + cGame.goalB) == (_goalA + _goalB)) {
            _score = _score.add(2);
        } else {
            isDoubleScore = false;
        }
        if(cGame.goalA == _goalA && cGame.goalB == _goalB) {
            _score = _score.add(3);
        } else {
            isDoubleScore = false;
        }
        if( ((cGame.goalA > cGame.goalB) && (_goalA > _goalB)) ||
            ((cGame.goalA < cGame.goalB) && (_goalA < _goalB)) ||
            ((cGame.goalA == cGame.goalB) && (_goalA == _goalB))) {
            _score = _score.add(1);
        } else {
            isDoubleScore = false;
        }
        if(isDoubleScore) {
            _score = _score.mul(2);
        }
        return _score;
    }
    function setBasePrice(uint256 _val) external onlyAdmin {
        require(_val > 0);
        basePrice = _val;
    }
    function setGameCloneFee(uint256 _val) external onlyAdmin {
        require(_val <= 10000);
        gameCloneFee = _val;
    }
    function setPrizeFundFactor(uint256 _val) external onlyAdmin {
        require(_val <= 10000);
        prizeFundFactor = _val;
    }
    function setPriceFactor(uint256 _val) external onlyAdmin {
        priceFactor = _val;
    }
    function gameEdit(uint256 _gameId, uint64 gameDate,
        Teams teamA, Teams teamB)
    external onlyAdmin {
        games[_gameId].gameDate = gameDate;
        games[_gameId].teamA = teamA;
        games[_gameId].teamB = teamB;
        emit GameChanged(_gameId, games[_gameId].gameDate, games[_gameId].teamA, games[_gameId].teamB,
            0, 0, true, 0, 0);
    }
    function gameResult(uint256 _gameId, uint256 goalA, uint256 goalB, bool odds, uint256 shotA, uint256 shotB)
    external onlyAdmin {
        games[_gameId].goalA = goalA;
        games[_gameId].goalB = goalB;
        games[_gameId].odds = odds;
        games[_gameId].shotA = shotA;
        games[_gameId].shotB = shotB;
        emit GameChanged(_gameId, games[_gameId].gameDate, games[_gameId].teamA, games[_gameId].teamB,
            goalA, goalB, odds, shotA, shotB);
    }
    function toForecastData(uint8 _goalA, uint8 _goalB, bool _odds, uint8 _shotA, uint8 _shotB)
    pure internal returns (uint) {
        uint forecastData;
        forecastData = forecastData << 8 | _goalA;
        forecastData = forecastData << 8 | _goalB;
        uint8 odds8 = _odds ? 1 : 0;
        forecastData = forecastData << 8 | odds8;
        forecastData = forecastData << 8 | _shotA;
        forecastData = forecastData << 8 | _shotB;
        return forecastData;
    }
}
