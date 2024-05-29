contract TokenTimelockControllerInterface {
  function activate() external;
  function createInvestorTokenTimeLock(
    address _beneficiary,
    uint256 _amount, 
    uint256 _start,
    address _tokenHolder
    ) external returns (bool);
}
