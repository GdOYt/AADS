contract ScriptExec {
  address public app_storage;
  address public provider;
  bytes32 public registry_exec_id;
  address public exec_admin;
  struct Instance {
    address current_provider;
    bytes32 current_registry_exec_id;
    bytes32 app_exec_id;
    bytes32 app_name;
    bytes32 version_name;
  }
  mapping (bytes32 => address) public deployed_by;
  mapping (bytes32 => Instance) public instance_info;
  mapping (address => Instance[]) public deployed_instances;
  mapping (bytes32 => bytes32[]) public app_instances;
  event AppInstanceCreated(address indexed creator, bytes32 indexed execution_id, bytes32 app_name, bytes32 version_name);
  event StorageException(bytes32 indexed execution_id, string message);
  modifier onlyAdmin() {
    require(msg.sender == exec_admin);
    _;
  }
  function () public payable { }
  function configure(address _exec_admin, address _app_storage, address _provider) public {
    require(app_storage == 0, "ScriptExec already configured");
    require(_app_storage != 0, 'Invalid input');
    exec_admin = _exec_admin;
    app_storage = _app_storage;
    provider = _provider;
    if (exec_admin == 0)
      exec_admin = msg.sender;
  }
  bytes4 internal constant EXEC_SEL = bytes4(keccak256('exec(address,bytes32,bytes)'));
  function exec(bytes32 _exec_id, bytes _calldata) external payable returns (bool success);
  bytes4 internal constant ERR = bytes4(keccak256('Error(string)'));
  function getAction(uint _ptr) internal pure returns (bytes4 action) {
    assembly {
      action := and(mload(_ptr), 0xffffffff00000000000000000000000000000000000000000000000000000000)
    }
  }
  function checkErrors(bytes32 _exec_id) internal {
    string memory message;
    bytes4 err_sel = ERR;
    assembly {
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, returndatasize)
      mstore(0x40, add(ptr, returndatasize))
      if eq(mload(ptr), and(err_sel, 0xffffffff00000000000000000000000000000000000000000000000000000000)) {
        message := add(0x24, ptr)
      }
    }
    if (bytes(message).length == 0)
      emit StorageException(_exec_id, "No error recieved");
    else
      emit StorageException(_exec_id, message);
  }
  function checkReturn() internal pure returns (bool success) {
    success = false;
    assembly {
      if eq(returndatasize, 0x60) {
        let ptr := mload(0x40)
        returndatacopy(ptr, 0, returndatasize)
        if iszero(iszero(mload(ptr))) { success := 1 }
        if iszero(iszero(mload(add(0x20, ptr)))) { success := 1 }
        if iszero(iszero(mload(add(0x40, ptr)))) { success := 1 }
      }
    }
    return success;
  }
  function createAppInstance(bytes32 _app_name, bytes _init_calldata) external returns (bytes32 exec_id, bytes32 version) {
    require(_app_name != 0 && _init_calldata.length >= 4, 'invalid input');
    (exec_id, version) = StorageInterface(app_storage).createInstance(
      msg.sender, _app_name, provider, registry_exec_id, _init_calldata
    );
    deployed_by[exec_id] = msg.sender;
    app_instances[_app_name].push(exec_id);
    Instance memory inst = Instance(
      provider, registry_exec_id, exec_id, _app_name, version
    );
    instance_info[exec_id] = inst;
    deployed_instances[msg.sender].push(inst);
    emit AppInstanceCreated(msg.sender, exec_id, _app_name, version);
  }
  function setRegistryExecID(bytes32 _exec_id) public onlyAdmin() {
    registry_exec_id = _exec_id;
  }
  function setProvider(address _provider) public onlyAdmin() {
    provider = _provider;
  }
  function setAdmin(address _admin) public onlyAdmin() {
    require(_admin != 0);
    exec_admin = _admin;
  }
  function getInstances(bytes32 _app_name) public view returns (bytes32[] memory) {
    return app_instances[_app_name];
  }
  function getDeployedLength(address _deployer) public view returns (uint) {
    return deployed_instances[_deployer].length;
  }
  bytes4 internal constant REGISTER_APP_SEL = bytes4(keccak256('registerApp(bytes32,address,bytes4[],address[])'));
  function getRegistryImplementation() public view returns (address index, address implementation) {
    index = StorageInterface(app_storage).getIndex(registry_exec_id);
    implementation = StorageInterface(app_storage).getTarget(registry_exec_id, REGISTER_APP_SEL);
  }
  function getInstanceImplementation(bytes32 _exec_id) public view
  returns (address index, bytes4[] memory functions, address[] memory implementations) {
    Instance memory app = instance_info[_exec_id];
    index = StorageInterface(app_storage).getIndex(app.current_registry_exec_id);
    (index, functions, implementations) = RegistryInterface(index).getVersionImplementation(
      app_storage, app.current_registry_exec_id, app.current_provider, app.app_name, app.version_name
    );
  }
}
