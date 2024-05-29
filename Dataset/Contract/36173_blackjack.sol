contract blackjack is casino {
  struct Game {
    bytes32 deck;
    bytes32 seedHash;
    address player;
    uint bet;
  }
  uint8[13] cardValues = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10];
  mapping(bytes32 => Game) games;
  mapping(bytes32 => uint8[]) splits;
  mapping(bytes32 => mapping(uint8 => bool)) doubled;
  mapping(bytes32 => bool) over;
  event NewGame(bytes32 indexed id, bytes32 deck, bytes32 srvSeed, bytes32 cSeed, address player, uint bet);
  event Result(bytes32 indexed id, address player, uint win);
  event Double(bytes32 indexed id, uint8 hand);
  event Split(bytes32 indexed id, uint8 hand);
  function blackjack(uint minBet, uint maxBet) casino(minBet, maxBet) public {
  }
  function initGame(address player, uint value, bytes32 deck, bytes32 srvSeed, bytes32 cSeed) onlyAuthorized public {
    assert(value >= minimumBet && value <= maximumBet);
    assert(!gameExists(srvSeed));
    games[srvSeed] = Game(deck, srvSeed, player, value);
    NewGame(srvSeed, deck, srvSeed, cSeed, player, value);
  }
  function double(bytes32 id, uint8 hand, uint value) onlyAuthorized public {
    Game storage game = games[id];
    require(value == game.bet);
    require(hand <= splits[id].length && !doubled[id][hand]);
    doubled[id][hand] = true;
    Double(id, hand);
  }
  function split(bytes32 id, uint8 hand, uint value) onlyAuthorized public {
    Game storage game = games[id];
    require(value == game.bet);
    require(splits[id].length < 3);
    splits[id].push(hand);
    Split(id, hand);
  }
  function surrender(bytes32 seed) onlyAuthorized public {
    var id = keccak256(seed);
    Game storage game = games[id];
    require(id == game.seedHash);
    require(!over[id]);
    over[id] = true;
    assert(msg.sender.call(bytes4(keccak256("shift(address,uint256)")), game.player, game.bet / 2));
    Result(id, game.player, game.bet / 2);
  }
  function stand(uint8[] deck, bytes32 seed, uint8[] numCards) onlyAuthorized public {
    var gameId = keccak256(seed);  
    Game storage game = games[gameId];
    assert(!over[gameId]);
    assert(checkDeck(gameId, deck, seed));
    assert(splits[gameId].length == numCards.length - 1);
    over[gameId] = true;
    uint win = determineOutcome(gameId, deck, numCards);
    if (win > 0) assert(msg.sender.call(bytes4(keccak256("shift(address,uint256)")), game.player, win));
    Result(gameId, game.player, win);
  }
  function gameExists(bytes32 id) constant public returns(bool success) {
    if (games[id].player != 0x0) return true;
    return false;
  }
  function checkDeck(bytes32 gameId, uint8[] deck, bytes32 seed) constant public returns(bool correct) {
    if (keccak256(convertToBytes(deck), seed) != games[gameId].deck) return false;
    return true;
  }
  function convertToBytes(uint8[] byteArray) internal constant returns(bytes b) {
    b = new bytes(byteArray.length);
    for (uint8 i = 0; i < byteArray.length; i++)
      b[i] = byte(byteArray[i]);
  }
  function determineOutcome(bytes32 gameId, uint8[] cards, uint8[] numCards) constant public returns(uint totalWin) {
    Game storage game = games[gameId];
    var playerValues = getPlayerValues(cards, numCards, splits[gameId]);
    var (dealerValue, dealerBJ) = getDealerValue(cards, sum(numCards));
    uint win;
    for (uint8 h = 0; h < numCards.length; h++) {
      uint8 playerValue = playerValues[h];
      if (playerValue > 21) win = 0;
      else if (numCards.length == 1 && playerValue == 21 && numCards[h] == 2 && !dealerBJ) {
        win = game.bet * 5 / 2;  
      }
      else if (playerValue > dealerValue || dealerValue > 21)
        win = game.bet * 2;
      else if (playerValue == dealerValue)
        win = game.bet;
      else
        win = 0;
      if (doubled[gameId][h]) win *= 2;
      totalWin += win;
    }
  }
  function getPlayerValues(uint8[] cards, uint8[] numCards, uint8[] pSplits) constant internal returns(uint8[5] playerValues) {
    uint8 cardIndex;
    uint8 splitIndex;
    (cardIndex, splitIndex, playerValues) = playHand(0, 0, 0, playerValues, cards, numCards, pSplits);
  }
  function playHand(uint8 hIndex, uint8 cIndex, uint8 sIndex, uint8[5] playerValues, uint8[] cards, uint8[] numCards, uint8[] pSplits) constant internal returns(uint8, uint8, uint8[5]) {
    playerValues[hIndex] = cardValues[cards[cIndex] % 13];
    cIndex = cIndex < 4 ? cIndex + 2 : cIndex + 1;
    while (sIndex < pSplits.length && pSplits[sIndex] == hIndex) {
      sIndex++;
      (cIndex, sIndex, playerValues) = playHand(sIndex, cIndex, sIndex, playerValues, cards, numCards, pSplits);
    }
    uint8 numAces = playerValues[hIndex] == 11 ? 1 : 0;
    uint8 card;
    for (uint8 i = 1; i < numCards[hIndex]; i++) {
      card = cards[cIndex] % 13;
      playerValues[hIndex] += cardValues[card];
      if (card == 0) numAces++;
      cIndex = cIndex < 4 ? cIndex + 2 : cIndex + 1;
    }
    while (numAces > 0 && playerValues[hIndex] > 21) {
      playerValues[hIndex] -= 10;
      numAces--;
    }
    return (cIndex, sIndex, playerValues);
  }
  function getDealerValue(uint8[] cards, uint8 numCards) constant internal returns(uint8 dealerValue, bool bj) {
    uint8 card = cards[1] % 13;
    uint8 card2 = cards[3] % 13;
    dealerValue = cardValues[card] + cardValues[card2];
    uint8 numAces;
    if (card == 0) numAces++;
    if (card2 == 0) numAces++;
    if (dealerValue > 21) {  
      dealerValue -= 10;
      numAces--;
    } else if (dealerValue == 21) {
      return (21, true);
    }
    uint8 i;
    while (dealerValue < 17) {
      card = cards[numCards + i + 2] % 13;
      dealerValue += cardValues[card];
      if (card == 0) numAces++;
      if (dealerValue > 21 && numAces > 0) {
        dealerValue -= 10;
        numAces--;
      }
      i++;
    }
  }
  function sum(uint8[] numbers) constant internal returns(uint8 s) {
    for (uint i = 0; i < numbers.length; i++) {
      s += numbers[i];
    }
  }
}
