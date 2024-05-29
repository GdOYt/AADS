contract BAYToken is SmartToken ( "daicobay token", "BAY", 18){
  constructor() {
    issue(msg.sender, 10**10 * 10**18);
  }
}
