contract VestedToken is LimitedTransferToken, Controlled {
  using SafeMath for uint;
  uint256 MAX_GRANTS_PER_ADDRESS = 20;
  struct TokenGrant {
    address granter;      
    uint256 value;        
    uint64 cliff;
    uint64 vesting;
    uint64 start;         
    bool revokable;
    bool burnsOnRevoke;   
  }  
  mapping (address => TokenGrant[]) public grants;
  event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint256 grantId);
  function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting,
    bool _revokable,
    bool _burnsOnRevoke
  ) onlyController public {
    require(_cliff > _start && _vesting > _cliff);
    require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);    
    uint count = grants[_to].push(
                TokenGrant(
                  _revokable ? msg.sender : 0,  
                  _value,
                  _cliff,
                  _vesting,
                  _start,
                  _revokable,
                  _burnsOnRevoke
                )
              );
    transfer(_to, _value);
    NewTokenGrant(msg.sender, _to, _value, count - 1);
  }
  function revokeTokenGrant(address _holder, uint _grantId) public {
    TokenGrant storage grant = grants[_holder][_grantId];
    require(grant.revokable);  
    require(grant.granter == msg.sender);  
    require(_grantId >= grants[_holder].length);
    address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;
    uint256 nonVested = nonVestedTokens(grant, uint64(now));
    delete grants[_holder][_grantId];
    grants[_holder][_grantId] = grants[_holder][grants[_holder].length - 1];
    grants[_holder].length -= 1;
    doTransfer(_holder, receiver, nonVested);
    Transfer(_holder, receiver, nonVested);
  }
    function revokeAllTokenGrants(address _holder) {
        var grantsCount = tokenGrantsCount(_holder);
        for (uint i = 0; i < grantsCount; i++) {
          revokeTokenGrant(_holder, 0);
        }
    }
  function transferableTokens(address holder, uint64 time) constant public returns (uint256) {
    uint256 grantIndex = tokenGrantsCount(holder);
    if (grantIndex == 0) return balanceOf(holder);  
    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
      nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));
    }
    uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);
    return SafeMath.min256(vestedTransferable, super.transferableTokens(holder, time));
  }
  function tokenGrantsCount(address _holder) constant returns (uint index) {
    return grants[_holder].length;
  }
  function calculateVestedTokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) constant returns (uint256)
    {
      if (time < cliff) return 0;
      if (time >= vesting) return tokens;
      uint256 vestedTokens = SafeMath.div(
                                    SafeMath.mul(
                                      tokens,
                                      SafeMath.sub(time, start)
                                      ),
                                    SafeMath.sub(vesting, start)
                                    );
      return vestedTokens;
  }
  function tokenGrant(address _holder, uint _grantId) constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {
    TokenGrant storage grant = grants[_holder][_grantId];
    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;
    revokable = grant.revokable;
    burnsOnRevoke = grant.burnsOnRevoke;
    vested = vestedTokens(grant, uint64(now));
  }
  function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return calculateVestedTokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }
  function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return grant.value.sub(vestedTokens(grant, time));
  }
  function lastTokenIsTransferableDate(address holder) constant public returns (uint64 date) {
    date = uint64(now);
    uint256 grantIndex = grants[holder].length;
    for (uint256 i = 0; i < grantIndex; i++) {
      date = SafeMath.max64(grants[holder][i].vesting, date);
    }
  }
}
