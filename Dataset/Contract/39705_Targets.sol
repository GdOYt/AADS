contract Targets {
  mapping(uint => uint) public counter;
  mapping(uint => uint) public target;
  function targetReached(uint id) constant returns (bool) {
    return (counter[id] >= target[id]);
  }
  function setTarget(uint id, uint _target) internal {
    target[id] = _target;
  }
  function addTowardsTarget(uint id, uint amount) 
    internal 
    returns (bool firstReached) 
  {
    firstReached = (counter[id] < target[id]) && 
                   (counter[id] + amount >= target[id]);
    counter[id] += amount;
  }
}
