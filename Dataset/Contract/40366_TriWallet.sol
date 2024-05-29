contract TriWallet {
  bool public thisIsFork;
  address public etcWallet;
  address public ethWallet;
  event ETCWalletCreated(address etcWalletAddress);
  event ETHWalletCreated(address ethWalletAddress);
  function TriWallet () {
    thisIsFork = BranchSender (0x23141df767233776f7cbbec497800ddedaa4c684).isRightBranch ();
    etcWallet = new BranchWallet (msg.sender, !thisIsFork);
    ethWallet = new BranchWallet (msg.sender, thisIsFork);
    ETCWalletCreated (etcWallet);
    ETHWalletCreated (ethWallet);
  }
  function distribute () {
    if (thisIsFork) {
      if (!ethWallet.send (this.balance)) throw;
    } else {
      if (!etcWallet.send (this.balance)) throw;
    }
  }
}
