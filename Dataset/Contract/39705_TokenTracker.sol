contract TokenTracker {
  uint public restrictedShare; 
  mapping(address => uint) public tokens;
  mapping(address => uint) public restrictions;
  uint public totalRestrictedTokens; 
  uint public totalUnrestrictedTokens; 
  uint public totalRestrictedAssignments; 
  uint public totalUnrestrictedAssignments; 
  bool public assignmentsClosed = false;
  uint public burnMultDen;
  uint public burnMultNom;
  function TokenTracker(uint _restrictedShare) {
    if (_restrictedShare >= 100) { throw; }
    restrictedShare = _restrictedShare;
  }
  function isUnrestricted() constant returns (bool) {
    return (assignmentsClosed && totalRestrictedTokens == 0);
  }
  function multFracCeiling(uint x, uint a, uint b) returns (uint) {
    if (a == 0) { return 0; }
    return (x * a + (b - 1)) / b; 
  }
  function isRegistered(address addr, bool restricted) constant returns (bool) {
    if (restricted) {
      return (restrictions[addr] > 0);
    } else {
      return (tokens[addr] > 0);
    }
  }
  function assign(address addr, uint tokenAmount, bool restricted) internal {
    if (assignmentsClosed) { throw; }
    tokens[addr] += tokenAmount;
    if (restricted) {
      totalRestrictedTokens += tokenAmount;
      totalRestrictedAssignments += 1;
      restrictions[addr] += tokenAmount;
    } else {
      totalUnrestrictedTokens += tokenAmount;
      totalUnrestrictedAssignments += 1;
    }
  }
  function closeAssignmentsIfOpen() internal {
    if (assignmentsClosed) { return; } 
    assignmentsClosed = true;
    uint totalTokensTarget = (totalUnrestrictedTokens * 100) / 
      (100 - restrictedShare);
    uint totalTokensExisting = totalRestrictedTokens + totalUnrestrictedTokens;
    uint totalBurn = 0; 
    if (totalTokensExisting > totalTokensTarget) {
      totalBurn = totalTokensExisting - totalTokensTarget; 
    }
    burnMultNom = totalBurn;
    burnMultDen = totalRestrictedTokens;
  }
  function unrestrict(address addr) internal returns (uint) {
    if (!assignmentsClosed) { throw; }
    uint restrictionsForAddr = restrictions[addr];
    if (restrictionsForAddr == 0) { throw; }
    uint burn = multFracCeiling(restrictionsForAddr, burnMultNom, burnMultDen);
    tokens[addr] -= burn;
    delete restrictions[addr];
    totalRestrictedTokens   -= restrictionsForAddr;
    totalUnrestrictedTokens += restrictionsForAddr - burn;
    return burn;
  }
}
