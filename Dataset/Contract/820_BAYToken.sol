contract BAYToken is SmartToken ( "DAICO Bay Token", "BAY", 18){
  constructor() {
    issue(msg.sender, 10**10 * 10**18);
  }
}
