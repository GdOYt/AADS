contract KnowledgeProxy is Proxy, UpgradableStorage {
  function upgradeTo(address imp) onlyOwner public payable {
    _implementation = imp;
    Upgradable(this).initialize.value(msg.value)();
    NewImplementation(imp);
  }
}
