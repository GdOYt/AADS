contract AssetRegistryStorage {
  string internal _name;
  string internal _symbol;
  string internal _description;
  uint256 internal _count;
  mapping(address => uint256[]) internal _assetsOf;
  mapping(uint256 => address) internal _holderOf;
  mapping(uint256 => uint256) internal _indexOfAsset;
  mapping(uint256 => string) internal _assetData;
  mapping(address => mapping(address => bool)) internal _operators;
  bool internal _reentrancy;
}
