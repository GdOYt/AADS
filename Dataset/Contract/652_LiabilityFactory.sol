contract LiabilityFactory {
    constructor(
        address _robot_liability_lib,
        address _lighthouse_lib,
        DutchAuction _auction,
        XRT _xrt,
        ENS _ens
    ) public {
        robotLiabilityLib = _robot_liability_lib;
        lighthouseLib = _lighthouse_lib;
        auction = _auction;
        xrt = _xrt;
        ens = _ens;
    }
    event NewLiability(address indexed liability);
    event NewLighthouse(address indexed lighthouse, string name);
    DutchAuction public auction;
    XRT public xrt;
    ENS public ens;
    uint256 public totalGasUtilizing = 0;
    mapping(address => uint256) public gasUtilizing;
    uint256 public constant gasEpoch = 347 * 10**10;
    uint256 public constant gasPrice = 10 * 10**9;
    mapping(bytes32 => bool) public usedHash;
    mapping(address => bool) public isLighthouse;
    address public robotLiabilityLib;
    address public lighthouseLib;
    function wnFromGas(uint256 _gas) public view returns (uint256) {
        if (auction.finalPrice() == 0)
            return _gas;
        uint256 epoch = totalGasUtilizing / gasEpoch;
        uint256 wn = _gas * 10**9 * gasPrice * 2**epoch / 3**epoch / auction.finalPrice();
        return wn < _gas ? _gas : wn;
    }
    modifier onlyLighthouse {
        require(isLighthouse[msg.sender]);
        _;
    }
    function usedHashGuard(bytes32 _hash) internal {
        require(!usedHash[_hash]);
        usedHash[_hash] = true;
    }
    function createLiability(
        bytes _ask,
        bytes _bid
    )
        external 
        onlyLighthouse
        returns (RobotLiability liability)
    {
        uint256 gasinit = gasleft();
        liability = new RobotLiability(robotLiabilityLib);
        emit NewLiability(liability);
        require(liability.call(abi.encodePacked(bytes4(0x82fbaa25), _ask)));  
        usedHashGuard(liability.askHash());
        require(liability.call(abi.encodePacked(bytes4(0x66193359), _bid)));  
        usedHashGuard(liability.bidHash());
        require(xrt.transferFrom(liability.promisor(),
                                 tx.origin,
                                 liability.lighthouseFee()));
        ERC20 token = liability.token();
        require(token.transferFrom(liability.promisee(),
                                   liability,
                                   liability.cost()));
        if (address(liability.validator()) != 0 && liability.validatorFee() > 0)
            require(xrt.transferFrom(liability.promisee(),
                                     liability,
                                     liability.validatorFee()));
        uint256 gas = gasinit - gasleft() + 110525;  
        totalGasUtilizing       += gas;
        gasUtilizing[liability] += gas;
     }
    function createLighthouse(
        uint256 _minimalFreeze,
        uint256 _timeoutBlocks,
        string  _name
    )
        external
        returns (address lighthouse)
    {
        bytes32 lighthouseNode
            = 0x3662a5d633e9a5ca4b4bd25284e1b343c15a92b5347feb9b965a2b1ef3e1ea1a;
        bytes32 subnode = keccak256(abi.encodePacked(lighthouseNode, keccak256(_name)));
        require(ens.resolver(subnode) == 0);
        lighthouse = new Lighthouse(lighthouseLib, _minimalFreeze, _timeoutBlocks);
        emit NewLighthouse(lighthouse, _name);
        isLighthouse[lighthouse] = true;
        ens.setSubnodeOwner(lighthouseNode, keccak256(_name), this);
        PublicResolver resolver = PublicResolver(ens.resolver(lighthouseNode));
        ens.setResolver(subnode, resolver);
        resolver.setAddr(subnode, lighthouse);
    }
    function liabilityFinalized(
        uint256 _gas
    )
        external
        returns (bool)
    {
        require(gasUtilizing[msg.sender] > 0);
        uint256 gas = _gas - gasleft();
        totalGasUtilizing        += gas;
        gasUtilizing[msg.sender] += gas;
        require(xrt.mint(tx.origin, wnFromGas(gasUtilizing[msg.sender])));
        return true;
    }
}
