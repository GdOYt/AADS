contract RSTBase is ERC20Token {
  address public board;
  address public owner;
  address public votingData;
  address public tokenData;
  address public feesData;
  uint256 public reserve;
  uint32  public crr;          
  uint256 public weiForToken;  
  uint8   public totalAccounts;
  modifier boardOnly() {
    require(msg.sender == board);
    _;
  }
}
