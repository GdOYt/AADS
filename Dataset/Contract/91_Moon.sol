contract Moon is usingOraclize{
    using Strings for string;
    struct Ticket {
      uint  amount;
    }
    uint gameNumber;
    uint allGameAmount;
    mapping(address => uint) earnings;
    mapping (address => uint) tickets;
    mapping (address => uint) ticketsForGame;
    uint numElements;
    address[] gameAddresses;
    uint numSums;
    uint[] gameSums;
    address beneficiaryOne;
    address beneficiaryTwo;
    address winner;
    uint gameBegin;
    uint gameEnd;
    uint totalAmount;
    uint numberOfPlayers;
    uint randomNumber;
    string concatFirst;
    string concatSecond;
    string concatRequest;
    function Moon() public {
        beneficiaryOne = 0x009a71cf732A6449a202A323AadE7a2BcFaAe3A8;
        beneficiaryTwo = 0x004e864e109fE8F3394CcDB74F64c160ac4C5ce4;
        gameBegin =  now;
        gameEnd = now + 1 days;
        totalAmount = 0;
        gameNumber = 1;
        allGameAmount = 0;
        numElements = 0;
        numberOfPlayers = 0;
        concatFirst = "random number between 0 and ";
        concatSecond = "";
        concatRequest = "";
    }
    function buyTicket() public payable {
        require((now <= gameEnd) || (totalAmount == 0));
        require(msg.value > 1000000000000000);
        require(ticketsForGame[msg.sender] < gameNumber);
        require(msg.value + totalAmount < 2000000000000000000000);
        require(randomNumber == 0);
        ticketsForGame[msg.sender] = gameNumber;
        tickets[msg.sender] = 0;
        insertAddress(msg.sender);
        insertSums(totalAmount);
        tickets[msg.sender] = msg.value;
        totalAmount += msg.value;
        numberOfPlayers += 1;
    }
    function withdraw() public returns (uint) {
        uint withdrawStatus = 0;
        uint amount = earnings[msg.sender];
        if (amount > 0) {
            withdrawStatus = 1;
            earnings[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                earnings[msg.sender] = amount;
                withdrawStatus = 2;
                return withdrawStatus;
            }
        }
        return withdrawStatus;
    }
    function __callback(bytes32 myid, string result) public {
       require(msg.sender == oraclize_cbAddress());
       require(randomNumber == 0);
       randomNumber = parseInt(result) * 10000000000000;
       return;
       myid;
   }
    function chooseRandomNumber() payable public {
        require(randomNumber == 0);
        require((now > gameEnd) && (totalAmount > 0));
        concatSecond = uint2str(totalAmount / 10000000000000);
        concatRequest = strConcat(concatFirst, concatSecond);
        oraclize_query("WolframAlpha", concatRequest);
    }
    function endGame() public {
        require(now > gameEnd);
        require(numElements > 0);
        require(randomNumber > 0);
        uint cursor = 0;
        uint inf = 0;
        uint sup = numElements - 1;
        uint test = 0;
        if(numElements > 1){
          if(randomNumber > gameSums[sup]){
            winner = gameAddresses[sup];
          } else{
            while(  (sup > inf + 1) && ( (randomNumber <= gameSums[cursor])  || ((cursor+1<numElements) && (randomNumber > gameSums[cursor+1])) ) ){
                  test = inf + (sup - inf) / 2;
                  if(randomNumber > gameSums[test]){
                    inf = test;
                  } else{
                    sup = test;
                  }
                  cursor = inf;
            }
            winner = gameAddresses[cursor];
          }
        }
        else{
          winner = gameAddresses[0];
        }
        uint amountOne = uint ( (4 * totalAmount) / 100 );
        uint amountTwo = uint ( (1 * totalAmount) / 100 );
        uint amountThree = totalAmount - amountOne - amountTwo;
        earnings[beneficiaryOne] += amountOne;
        earnings[beneficiaryTwo] += amountTwo;
        earnings[winner] += amountThree;
        gameNumber += 1;
        allGameAmount += totalAmount;
        gameBegin = now;
        gameEnd = now + 1 days;
        totalAmount = 0;
        randomNumber = 0;
        numberOfPlayers = 0;
        clearAddresses();
        clearSums();
    }
    function myEarnings() public view returns (uint){
       return earnings[msg.sender];
    }
    function getWinnerAddress() public view returns (address){
       return winner;
    }
    function getGameBegin() public view returns (uint) {
      return gameBegin;
    }
    function getGameEnd() public view returns (uint) {
      return gameEnd;
    }
    function getTotalAmount() public view returns (uint){
      return totalAmount;
    }
    function getGameAddresses(uint index) public view returns(address){
        return gameAddresses[index];
    }
    function getGameSums(uint index) public view returns(uint){
        return gameSums[index];
    }
    function getGameNumber() public view returns (uint) {
        return gameNumber;
    }
    function getNumberOfPlayers() public view returns (uint) {
        return numberOfPlayers;
    }
    function getAllGameAmount() public view returns (uint) {
        return allGameAmount;
    }
    function getRandomNumber() public view returns (uint){
        return randomNumber;
    }
    function getMyStake() public view returns (uint){
        return tickets[msg.sender];
    }
    function getNumSums() public view returns (uint){
      return numSums;
    }
    function getNumElements() public view returns (uint){
      return numElements;
    }
    function insertAddress(address value) private {
      if(numElements == gameAddresses.length) {
          gameAddresses.length += 1;
      }
      gameAddresses[numElements++] = value;
    }
    function clearAddresses() private{
        numElements = 0;
    }
    function insertSums(uint value) private{
      if(numSums == gameSums.length) {
          gameSums.length += 1;
      }
      gameSums[numSums++] = value;
    }
    function clearSums() private{
        numSums = 0;
    }
}
