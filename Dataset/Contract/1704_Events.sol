contract Events {
  event Started (
    uint _time
  );
  event Bought (
    address indexed _player,
    address indexed _referral,
    uint _countryId,
    uint _tickets,
    uint _value,
    uint _excess
  );
  event Promoted (
    address indexed _player,
    uint _goldenTickets,
    uint _endTime
  );
  event Withdrew (
    address indexed _player,
    uint _amount
  );
  event Registered (
    string _code, address indexed _referral
  );
  event Won (
    address indexed _winner, uint _pot
  );
}
