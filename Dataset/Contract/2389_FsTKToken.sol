contract FsTKToken {
  enum DelegateMode { PublicMsgSender, PublicTxOrigin, PrivateMsgSender, PrivateTxOrigin }
  event Consume(address indexed from, uint256 value, bytes32 challenge);
  event IncreaseNonce(address indexed from, uint256 nonce);
  event SetupDirectDebit(address indexed debtor, address indexed receiver, DirectDebitInfo info);
  event TerminateDirectDebit(address indexed debtor, address indexed receiver);
  event WithdrawDirectDebitFailure(address indexed debtor, address indexed receiver);
  event SetMetadata(string metadata);
  event SetLiquid(bool liquidity);
  event SetDelegate(bool isDelegateEnable);
  event SetDirectDebit(bool isDirectDebitEnable);
  struct DirectDebitInfo {
    uint256 amount;
    uint256 startTime;
    uint256 interval;
  }
  struct DirectDebit {
    DirectDebitInfo info;
    uint256 epoch;
  }
  struct Instrument {
    uint256 allowance;
    DirectDebit directDebit;
  }
  struct Account {
    uint256 balance;
    uint256 nonce;
    mapping (address => Instrument) instruments;
  }
  function spendableAllowance(address owner, address spender) public view returns (uint256);
  function transfer(uint256[] data) public returns (bool);
  function transferAndCall(address to, uint256 value, bytes data) public payable returns (bool);
  function nonceOf(address owner) public view returns (uint256);
  function increaseNonce() public returns (bool);
  function delegateTransferAndCall(
    uint256 nonce,
    uint256 fee,
    uint256 gasAmount,
    address to,
    uint256 value,
    bytes data,
    DelegateMode mode,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public returns (bool);
  function directDebit(address debtor, address receiver) public view returns (DirectDebit);
  function setupDirectDebit(address receiver, DirectDebitInfo info) public returns (bool);
  function terminateDirectDebit(address receiver) public returns (bool);
  function withdrawDirectDebit(address debtor) public returns (bool);
  function withdrawDirectDebit(address[] debtors, bool strict) public returns (bool);
}
