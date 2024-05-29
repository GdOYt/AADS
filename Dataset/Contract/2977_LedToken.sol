contract LedToken is Controllable {
  using SafeMath for uint256;
  LedTokenInterface public parentToken;
  TokenFactoryInterface public tokenFactory;
  string public name;
  string public symbol;
  string public version;
  uint8 public decimals;
  uint256 public parentSnapShotBlock;
  uint256 public creationBlock;
  bool public transfersEnabled;
  bool public masterTransfersEnabled;
  address public masterWallet = 0x865e785f98b621c5fdde70821ca7cea9eeb77ef4;
  struct Checkpoint {
    uint128 fromBlock;
    uint128 value;
  }
  Checkpoint[] totalSupplyHistory;
  mapping(address => Checkpoint[]) balances;
  mapping (address => mapping (address => uint)) allowed;
  bool public mintingFinished = false;
  bool public presaleBalancesLocked = false;
  uint256 public totalSupplyAtCheckpoint;
  event MintFinished();
  event NewCloneToken(address indexed cloneToken);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
  event Transfer(address indexed from, address indexed to, uint256 value);
  constructor(
    address _tokenFactory,
    address _parentToken,
    uint256 _parentSnapShotBlock,
    string _tokenName,
    string _tokenSymbol
    ) public {
      tokenFactory = TokenFactoryInterface(_tokenFactory);
      parentToken = LedTokenInterface(_parentToken);
      parentSnapShotBlock = _parentSnapShotBlock;
      name = _tokenName;
      symbol = _tokenSymbol;
      decimals = 18;
      transfersEnabled = false;
      masterTransfersEnabled = false;
      creationBlock = block.number;
      version = '0.1';
  }
  function totalSupply() public constant returns (uint256) {
    return totalSupplyAt(block.number);
  }
  function totalSupplyAt(uint256 _blockNumber) public constant returns(uint256) {
    if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
        if (address(parentToken) != 0x0) {
            return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
        } else {
            return 0;
        }
    } else {
        return getValueAt(totalSupplyHistory, _blockNumber);
    }
  }
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }
  function balanceOfAt(address _owner, uint256 _blockNumber) public constant returns (uint256) {
    if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
        if (address(parentToken) != 0x0) {
            return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
        } else {
            return 0;
        }
    } else {
        return getValueAt(balances[_owner], _blockNumber);
    }
  }
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    return doTransfer(msg.sender, _to, _amount);
  }
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
    require(allowed[_from][msg.sender] >= _amount);
    allowed[_from][msg.sender] -= _amount;
    return doTransfer(_from, _to, _amount);
  }
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    require(transfersEnabled);
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
    approve(_spender, _amount);
    ApproveAndCallReceiver(_spender).receiveApproval(
        msg.sender,
        _amount,
        this,
        _extraData
    );
    return true;
  }
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  function doTransfer(address _from, address _to, uint256 _amount) internal returns(bool) {
    if (msg.sender != masterWallet) {
      require(transfersEnabled);
    } else {
      require(masterTransfersEnabled);
    }
    require(_amount > 0);
    require(parentSnapShotBlock < block.number);
    require((_to != address(0)) && (_to != address(this)));
    uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
    require(previousBalanceFrom >= _amount);
    updateValueAtNow(balances[_from], previousBalanceFrom - _amount);
    uint256 previousBalanceTo = balanceOfAt(_to, block.number);
    require(previousBalanceTo + _amount >= previousBalanceTo);  
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);
    emit Transfer(_from, _to, _amount);
    return true;
  }
  function mint(address _owner, uint256 _amount) public onlyController canMint returns (bool) {
    uint256 curTotalSupply = totalSupply();
    uint256 previousBalanceTo = balanceOf(_owner);
    require(curTotalSupply + _amount >= curTotalSupply);  
    require(previousBalanceTo + _amount >= previousBalanceTo);  
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
    emit Transfer(0, _owner, _amount);
    return true;
  }
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  function importPresaleBalances(address[] _addresses, uint256[] _balances) public onlyController returns (bool) {
    require(presaleBalancesLocked == false);
    for (uint256 i = 0; i < _addresses.length; i++) {
      totalSupplyAtCheckpoint += _balances[i];
      updateValueAtNow(balances[_addresses[i]], _balances[i]);
      updateValueAtNow(totalSupplyHistory, totalSupplyAtCheckpoint);
      emit Transfer(0, _addresses[i], _balances[i]);
    }
    return true;
  }
  function lockPresaleBalances() public onlyController returns (bool) {
    presaleBalancesLocked = true;
    return true;
  }
  function finishMinting() public onlyController returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
  function enableTransfers(bool _value) public onlyController {
    transfersEnabled = _value;
  }
  function enableMasterTransfers(bool _value) public onlyController {
    masterTransfersEnabled = _value;
  }
  function getValueAt(Checkpoint[] storage _checkpoints, uint256 _block) constant internal returns (uint256) {
      if (_checkpoints.length == 0)
        return 0;
      if (_block >= _checkpoints[_checkpoints.length-1].fromBlock)
        return _checkpoints[_checkpoints.length-1].value;
      if (_block < _checkpoints[0].fromBlock)
        return 0;
      uint256 min = 0;
      uint256 max = _checkpoints.length-1;
      while (max > min) {
          uint256 mid = (max + min + 1) / 2;
          if (_checkpoints[mid].fromBlock<=_block) {
              min = mid;
          } else {
              max = mid-1;
          }
      }
      return _checkpoints[min].value;
  }
  function updateValueAtNow(Checkpoint[] storage _checkpoints, uint256 _value) internal {
      if ((_checkpoints.length == 0) || (_checkpoints[_checkpoints.length-1].fromBlock < block.number)) {
              Checkpoint storage newCheckPoint = _checkpoints[_checkpoints.length++];
              newCheckPoint.fromBlock = uint128(block.number);
              newCheckPoint.value = uint128(_value);
          } else {
              Checkpoint storage oldCheckPoint = _checkpoints[_checkpoints.length-1];
              oldCheckPoint.value = uint128(_value);
          }
  }
  function min(uint256 a, uint256 b) internal pure returns (uint) {
      return a < b ? a : b;
  }
  function createCloneToken(uint256 _snapshotBlock, string _name, string _symbol) public returns(address) {
      if (_snapshotBlock == 0) {
        _snapshotBlock = block.number;
      }
      if (_snapshotBlock > block.number) {
        _snapshotBlock = block.number;
      }
      LedToken cloneToken = tokenFactory.createCloneToken(
          this,
          _snapshotBlock,
          _name,
          _symbol
        );
      cloneToken.transferControl(msg.sender);
      emit NewCloneToken(address(cloneToken));
      return address(cloneToken);
    }
}