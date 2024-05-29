contract RBAC {
  using Roles for Roles.Role;
  mapping (string => Roles.Role) private roles;
  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }
}
