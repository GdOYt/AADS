contract BaseRabbit  is Ownable {
    event SendBunny(address newOwnerBunny, uint32 bunnyId);
    event StopMarket(uint32 bunnyId);
    event StartMarket(uint32 bunnyId, uint money);
    event BunnyBuy(uint32 bunnyId, uint money);  
    event EmotherCount(uint32 mother, uint summ);
    event NewBunny(uint32 bunnyId, uint dnk, uint256 blocknumber, uint breed );
    event ChengeSex(uint32 bunnyId, bool sex, uint256 price);
    event SalaryBunny(uint32 bunnyId, uint cost);
    event CreateChildren(uint32 matron, uint32 sire, uint32 child);
    event BunnyName(uint32 bunnyId, string name);
    event BunnyDescription(uint32 bunnyId, string name);
    event CoolduwnMother(uint32 bunnyId, uint num);
    event Transfer(address from, address to, uint32 tokenId);
    event Approval(address owner, address approved, uint32 tokenId);
    event OwnerBunnies(address owner, uint32  tokenId);
    address public  myAddr_test = 0x982a49414fD95e3268D3559540A67B03e40AcD64;
    using SafeMath for uint256;
    bool pauseSave = false;
    uint256 bigPrice = 0.0005 ether;
    uint public commission_system = 5;
    uint32 public lastIdGen0;
    uint public totalGen0 = 0;
    uint public lastTimeGen0;
    uint public timeRangeCreateGen0 = 1;
    uint public promoGen0 = 2500;
    uint public promoMoney = 1*bigPrice;
    bool public promoPause = false;
    function setPromoGen0(uint _promoGen0) public onlyOwner {
        promoGen0 = _promoGen0;
    }
    function setPromoPause() public onlyOwner {
        promoPause = !promoPause;
    }
    function setPromoMoney(uint _promoMoney) public onlyOwner {
        promoMoney = _promoMoney;
    }
    modifier timeRange() {
        require((lastTimeGen0+timeRangeCreateGen0) < now);
        _;
    } 
    mapping(uint32 => uint) public totalSalaryBunny;
    mapping(uint32 => uint32[5]) public rabbitMother;
    mapping(uint32 => uint) public motherCount;
    mapping(uint32 => uint) public rabbitBreedCount;
    mapping(uint32 => uint)  public rabbitSirePrice;
    mapping(uint => uint32[]) public sireGenom;
    mapping (uint32 => uint) mapDNK;
    uint32[12] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(4 minutes),
        uint32(8 minutes),
        uint32(16 minutes),
        uint32(32 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days)
    ];
    struct Rabbit { 
        uint32 mother;
        uint32 sire; 
        uint birthblock;
        uint birthCount;
        uint birthLastTime;
        uint role;
        uint genome;
    }
    Rabbit[]  public rabbits;
    mapping (uint32 => address) public rabbitToOwner; 
    mapping(address => uint32[]) public ownerBunnies;
    mapping (uint32 => string) rabbitDescription;
    mapping (uint32 => string) rabbitName; 
    mapping (uint32 => bool) giffblock; 
    mapping (address => bool) ownerGennezise;
}
