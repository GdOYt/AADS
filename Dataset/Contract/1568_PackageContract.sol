contract PackageContract is ReferTokenERC20Basic, MintableToken {
    uint constant daysPerMonth = 30;
    mapping(uint => mapping(string => uint256)) internal packageType;
    struct Package {
        uint256 since;
        uint256 tokenValue;
        uint256 kindOf;
    }
    mapping(address => Package) internal userPackages;
    function PackageContract() public {
        packageType[2]['fee'] = 30;
        packageType[2]['reward'] = 20;
        packageType[4]['fee'] = 35;
        packageType[4]['reward'] = 25;
    }
    function depositMint(address _to, uint256 _amount, uint _kindOfPackage) canMint internal returns (bool) {
        return depositMintSince(_to, _amount, _kindOfPackage, now);
    }
    function depositMintSince(address _to, uint256 _amount, uint _kindOfPackage, uint since) canMint internal returns (bool) {
        totalSupply = totalSupply.add(_amount);
        Package memory pac;
        pac = Package({since : since, tokenValue : _amount, kindOf : _kindOfPackage});
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        userPackages[_to] = pac;
        return true;
    }
    function depositBalanceOf(address _owner) public view returns (uint256 balance) {
        return userPackages[_owner].tokenValue;
    }
    function getKindOfPackage(address _owner) public view returns (uint256) {
        return userPackages[_owner].kindOf;
    }
}
