contract RegistryExec is ScriptExec {
  struct Registry {
    address index;
    address implementation;
  }
  mapping (bytes32 => Registry) public registry_instance_info;
  mapping (address => Registry[]) public deployed_registry_instances;
  event RegistryInstanceCreated(address indexed creator, bytes32 indexed execution_id, address index, address implementation);
  bytes4 internal constant EXEC_SEL = bytes4(keccak256('exec(address,bytes32,bytes)'));
  function exec(bytes32 _exec_id, bytes _calldata) external payable returns (bool success) {
    bytes4 sel = getSelector(_calldata);
    require(
      sel != this.registerApp.selector &&
      sel != this.registerAppVersion.selector &&
      sel != UPDATE_INST_SEL &&
      sel != UPDATE_EXEC_SEL
    );
    if (address(app_storage).call.value(msg.value)(abi.encodeWithSelector(
      EXEC_SEL, msg.sender, _exec_id, _calldata
    )) == false) {
      checkErrors(_exec_id);
      address(msg.sender).transfer(address(this).balance);
      return false;
    }
    success = checkReturn();
    require(success, 'Execution failed');
    address(msg.sender).transfer(address(this).balance);
  }
  function getSelector(bytes memory _calldata) internal pure returns (bytes4 selector) {
    assembly {
      selector := and(
        mload(add(0x20, _calldata)),
        0xffffffff00000000000000000000000000000000000000000000000000000000
      )
    }
  }
  function createRegistryInstance(address _index, address _implementation) external onlyAdmin() returns (bytes32 exec_id) {
    require(_index != 0 && _implementation != 0, 'Invalid input');
    exec_id = StorageInterface(app_storage).createRegistry(_index, _implementation);
    require(exec_id != 0, 'Invalid response from storage');
    if (registry_exec_id == 0)
      registry_exec_id = exec_id;
    Registry memory reg = Registry(_index, _implementation);
    deployed_by[exec_id] = msg.sender;
    registry_instance_info[exec_id] = reg;
    deployed_registry_instances[msg.sender].push(reg);
    emit RegistryInstanceCreated(msg.sender, exec_id, _index, _implementation);
  }
  function registerApp(bytes32 _app_name, address _index, bytes4[] _selectors, address[] _implementations) external onlyAdmin() {
    require(_app_name != 0 && _index != 0, 'Invalid input');
    require(_selectors.length == _implementations.length && _selectors.length != 0, 'Invalid input');
    require(app_storage != 0 && registry_exec_id != 0 && provider != 0, 'Invalid state');
    uint emitted;
    uint paid;
    uint stored;
    (emitted, paid, stored) = StorageInterface(app_storage).exec(msg.sender, registry_exec_id, msg.data);
    require(emitted == 0 && paid == 0 && stored != 0, 'Invalid state change');
  }
  function registerAppVersion(bytes32 _app_name, bytes32 _version_name, address _index, bytes4[] _selectors, address[] _implementations) external onlyAdmin() {
    require(_app_name != 0 && _version_name != 0 && _index != 0, 'Invalid input');
    require(_selectors.length == _implementations.length && _selectors.length != 0, 'Invalid input');
    require(app_storage != 0 && registry_exec_id != 0 && provider != 0, 'Invalid state');
    uint emitted;
    uint paid;
    uint stored;
    (emitted, paid, stored) = StorageInterface(app_storage).exec(msg.sender, registry_exec_id, msg.data);
    require(emitted == 0 && paid == 0 && stored != 0, 'Invalid state change');
  }
  bytes4 internal constant UPDATE_INST_SEL = bytes4(keccak256('updateInstance(bytes32,bytes32,bytes32)'));
  function updateAppInstance(bytes32 _exec_id) external returns (bool success) {
    require(_exec_id != 0 && msg.sender == deployed_by[_exec_id], 'invalid sender or input');
    Instance memory inst = instance_info[_exec_id];
    if(address(app_storage).call(
      abi.encodeWithSelector(EXEC_SEL,             
        inst.current_provider,                     
        _exec_id,                                  
        abi.encodeWithSelector(UPDATE_INST_SEL,    
          inst.app_name,                           
          inst.version_name,                       
          inst.current_registry_exec_id            
        )
      )
    ) == false) {
      checkErrors(_exec_id);
      return false;
    }
    success = checkReturn();
    require(success, 'Execution failed');
    address registry_idx = StorageInterface(app_storage).getIndex(inst.current_registry_exec_id);
    bytes32 latest_version  = RegistryInterface(registry_idx).getLatestVersion(
      app_storage,
      inst.current_registry_exec_id,
      inst.current_provider,
      inst.app_name
    );
    require(latest_version != 0, 'invalid latest version');
    instance_info[_exec_id].version_name = latest_version;
  }
  bytes4 internal constant UPDATE_EXEC_SEL = bytes4(keccak256('updateExec(address)'));
  function updateAppExec(bytes32 _exec_id, address _new_exec_addr) external returns (bool success) {
    require(_exec_id != 0 && msg.sender == deployed_by[_exec_id] && address(this) != _new_exec_addr && _new_exec_addr != 0, 'invalid input');
    if(address(app_storage).call(
      abi.encodeWithSelector(EXEC_SEL,                             
        msg.sender,                                                
        _exec_id,                                                  
        abi.encodeWithSelector(UPDATE_EXEC_SEL, _new_exec_addr)    
      )
    ) == false) {
      checkErrors(_exec_id);
      return false;
    }
    success = checkReturn();
    require(success, 'Execution failed');
  }
}
