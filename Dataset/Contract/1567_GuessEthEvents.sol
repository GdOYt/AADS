contract GuessEthEvents{
    event drawLog(uint,uint,uint);
    event guessEvt(
        address indexed playerAddr,
        uint[] numbers, uint amount
        );
    event winnersEvt(
        uint blockNumber,
        address indexed playerAddr,
        uint amount,
        uint winAmount
        );
    event withdrawEvt(
        address indexed to,
        uint256 value
        );
    event drawEvt(
        uint indexed blocknumberr,
        uint number
        );
    event sponseEvt(
        address indexed addr,
        uint amount
        );
    event pauseGameEvt(
        bool pause
        );
    event setOddsEvt(
        uint odds
        );
}
