contract StepFunction {
  uint public phaseLength;
  uint public nSteps;
  uint public step;
  function StepFunction(uint _phaseLength, uint _initialValue, uint _nSteps) {
    if (_nSteps > _phaseLength) { throw; } 
    step = _initialValue / _nSteps;
    if ( step * _nSteps != _initialValue) { throw; } 
    phaseLength = _phaseLength;
    nSteps = _nSteps; 
  }
  function getStepFunction(uint elapsedTime) constant returns (uint) {
    if (elapsedTime >= phaseLength) { throw; }
    uint timeLeft  = phaseLength - elapsedTime - 1; 
    uint stepsLeft = ((nSteps + 1) * timeLeft) / phaseLength; 
    return stepsLeft * step;
  }
}
