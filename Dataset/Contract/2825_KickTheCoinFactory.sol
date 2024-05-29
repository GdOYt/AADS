contract KickTheCoinFactory {
    address[] public games;
    address[] public founders;
    mapping(address => address[]) founderToCreatedGames;
    mapping(address => uint) gameToBlockCreated;
    mapping(address => address) gameToWithdraw;
    address public admin;
    address public coldAdmin = 0x46937732313A6c856354f4E5Ea012DfD10186B9A;
    uint public costToCreateGame;
    bool public isDisabled;
    event GameCreated(address founder, address _game, address _withdraw, uint _costToKickTheCoin, uint _numberOfBlocksPerKick);
    function KickTheCoinFactory() {
        admin = msg.sender;
        isDisabled = false;
    }
    function createGame(uint _costToKickTheCoin, uint _numberOfBlocksPerKick)
    public
    payable
    {
        require(!isDisabled);
        if (costToCreateGame > 0) {
            require(msg.value == costToCreateGame);
        }
        if (msg.value > 0) {
            admin.transfer(msg.value);
        }
        KickTheCoin _game = new KickTheCoin();
        _game.changeGameParameters(_costToKickTheCoin, _numberOfBlocksPerKick);
        games.push(_game);
        if (founderToCreatedGames[msg.sender].length == 0) {
            founders.push(msg.sender);
        }
        founderToCreatedGames[msg.sender].push(_game);
        WithdrawFromKickTheCoin _withdraw = new WithdrawFromKickTheCoin();
        _withdraw.setKtcAddress(_game, true);
        gameToWithdraw[_game] = _withdraw;
        gameToBlockCreated[_game] = block.number;
        GameCreated(msg.sender, _game, _withdraw, _costToKickTheCoin, _numberOfBlocksPerKick);
    }
    function setDisabled(bool _isDisabled)
    {
        require(msg.sender == admin);
        isDisabled = _isDisabled;
    }
    function setCostToCreateGame(uint _costToCreateGame)
    public
    {
        require(msg.sender == admin);
        costToCreateGame = _costToCreateGame;
    }
    function setAdmin(address _newAdmin)
    public
    {
        require(msg.sender == admin || msg.sender == coldAdmin);
        admin = _newAdmin;
    }
    function getFoundersGames(address _founder)
    public
    constant
    returns (address[])
    {
        return founderToCreatedGames[_founder];
    }
    function getWithdraw(address _game)
    public
    constant
    returns(address _withdraw)
    {
        _withdraw = gameToWithdraw[_game];
    }
    function getInfo()
    constant
    returns (
        address[] _games,
        address[] _founders,
        address _admin,
        uint _costToCreateGame,
        bool _isDisabled
    )
    {
        _games = games;
        _isDisabled = isDisabled;
        _admin = admin;
        _costToCreateGame = costToCreateGame;
        _founders = founders;
    }
    function()
    payable
    {
        admin.transfer(msg.value);
    }
}
