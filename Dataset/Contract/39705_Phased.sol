contract Phased {
  uint[] public phaseEndTime;
  uint public N; 
  mapping(uint => uint) public maxDelay; 
  function getPhaseAtTime(uint time) constant returns (uint n) {
    if (time > now) { throw; }
    while (n < N && phaseEndTime[n] <= time) {
      n++;
    }
  }
  function isPhase(uint time, uint n) constant returns (bool) {
    if (time > now) { throw; }
    if (n >= N) { throw; }
    if (n > 0 && phaseEndTime[n-1] > time) { return false; } 
    if (n < N && time >= phaseEndTime[n]) { return false; } 
    return true; 
  }
  function getPhaseStartTime(uint n) constant returns (uint) {
    if (n == 0) { throw; }
    return phaseEndTime[n-1];
  }
  function addPhase(uint time) internal {
    if (N > 0 && time <= phaseEndTime[N-1]) { throw; } 
    if (time <= now) { throw; }
    phaseEndTime.push(time);
    N++;
  }
  function setMaxDelay(uint i, uint timeDelta) internal {
    if (i >= N) { throw; }
    maxDelay[i] = timeDelta;
  }
  function delayPhaseEndBy(uint n, uint timeDelta) internal {
    if (n >= N) { throw; }
    if (now >= phaseEndTime[n]) { throw; }
    if (timeDelta > maxDelay[n]) { throw; }
    maxDelay[n] -= timeDelta;
    for (uint i = n; i < N; i++) {
      phaseEndTime[i] += timeDelta;
    }
  }
  function endCurrentPhaseIn(uint timeDelta) internal {
    uint n = getPhaseAtTime(now);
    if (n >= N) { throw; }
    if (timeDelta == 0) { 
      timeDelta = 1; 
    }
    if (now + timeDelta < phaseEndTime[n]) { 
      phaseEndTime[n] = now + timeDelta;
    }
  }
}
