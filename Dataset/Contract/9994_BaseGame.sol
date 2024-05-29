contract BaseGame is ERC721Token {
    event NewAccount(address owner, uint tokenId, uint parentTokenId, uint blockNumber);
    event NewForecast(address owner, uint tokenId, uint forecastId, uint _gameId,
        uint _forecastData);
    struct Token {
        uint createBlockNumber;
        uint parentId;
    }
    enum Teams { DEF,
        RUS, SAU, EGY, URY,      
        PRT, ESP, MAR, IRN,      
        FRA, AUS, PER, DNK,      
        ARG, ISL, HRV, NGA,      
        BRA, CHE, CRI, SRB,      
        DEU, MEX, SWE, KOR,      
        BEL, PAN, TUN, GBR,      
        POL, SEN, COL, JPN       
    }
    event GameChanged(uint _gameId, uint64 gameDate, Teams teamA, Teams teamB,
        uint goalA, uint goalB, bool odds, uint shotA, uint shotB);
    struct Game {
        uint64 gameDate;
        Teams teamA;
        Teams teamB;
        uint goalA;
        uint goalB;
        bool odds;
        uint shotA;
        uint shotB;
        uint[] forecasts;
    }
    struct Forecast {
        uint gameId;
        uint forecastBlockNumber;
        uint forecastData;
    }
    Token[] tokens;
    mapping (uint => Game) games;
    Forecast[] forecasts;
    mapping (uint => uint) internal forecastToToken;
    mapping (uint => uint[]) internal tokenForecasts;
    constructor(string _name, string _symbol) ERC721Token(_name, _symbol) public {}
    function _createToken(uint _parentId, address _owner) internal whenNotPaused
    returns (uint) {
        Token memory _token = Token({
            createBlockNumber: block.number,
            parentId: _parentId
            });
        uint newTokenId = tokens.push(_token) - 1;
        emit NewAccount(_owner, newTokenId, uint(_token.parentId), uint(_token.createBlockNumber));
        _mint(_owner, newTokenId);
        return newTokenId;
    }
    function _createForecast(uint _tokenId, uint _gameId, uint _forecastData) internal whenNotPaused returns (uint) {
        require(_tokenId < tokens.length);
        Forecast memory newForecast = Forecast({
            gameId: _gameId,
            forecastBlockNumber: block.number,
            forecastData: _forecastData
            });
        uint newForecastId = forecasts.push(newForecast) - 1;
        forecastToToken[newForecastId] = _tokenId;
        tokenForecasts[_tokenId].push(newForecastId);
        games[_gameId].forecasts.push(newForecastId);
        emit NewForecast(tokenOwner[_tokenId], _tokenId, newForecastId, _gameId, _forecastData);
        return newForecastId;
    }    
}
