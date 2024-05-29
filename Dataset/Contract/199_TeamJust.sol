contract TeamJust {
    JIincForwarderInterface private Jekyll_Island_Inc = JIincForwarderInterface(0x0);
    MSFun.Data private msData;
    function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}
    function checkData(bytes32 _whatFunction) onlyAdmins() public view returns(bytes32 message_data, uint256 signature_count) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}
    function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(bytes32, bytes32, bytes32) {return(this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}
    struct Admin {
        bool isAdmin;
        bool isDev;
        bytes32 name;
    }
    mapping (address => Admin) admins_;
    uint256 adminCount_;
    uint256 devCount_;
    uint256 requiredSignatures_;
    uint256 requiredDevSignatures_;
    constructor()
        public
    {
        address inventor = 0x0D78E82ECEd57aC3CE65fE3B828f4d52fF712f31;
        address mantso   = 0x0D78E82ECEd57aC3CE65fE3B828f4d52fF712f31;
        address justo    = 0x0D78E82ECEd57aC3CE65fE3B828f4d52fF712f31;
        address sumpunk  = 0x0D78E82ECEd57aC3CE65fE3B828f4d52fF712f31;
		address deployer = 0x8Ba912954aedfeAF2978a1864e486fFbE4D5940f;
        admins_[inventor] = Admin(true, true, "inventor");
        admins_[mantso]   = Admin(true, true, "mantso");
        admins_[justo]    = Admin(true, true, "justo");
        admins_[sumpunk]  = Admin(true, true, "sumpunk");
		admins_[deployer] = Admin(true, true, "deployer");
        adminCount_ = 5;
        devCount_ = 5;
        requiredSignatures_ = 1;
        requiredDevSignatures_ = 1;
    }
    function ()
        public
        payable
    {
        Jekyll_Island_Inc.deposit.value(address(this).balance)();
    }
    function setup(address _addr)
        onlyDevs()
        public
    {
        require( address(Jekyll_Island_Inc) == address(0) );
        Jekyll_Island_Inc = JIincForwarderInterface(_addr);
    }    
    modifier onlyDevs()
    {
        require(admins_[msg.sender].isDev == true, "onlyDevs failed - msg.sender is not a dev");
        _;
    }
    modifier onlyAdmins()
    {
        require(admins_[msg.sender].isAdmin == true, "onlyAdmins failed - msg.sender is not an admin");
        _;
    }
    function addAdmin(address _who, bytes32 _name, bool _isDev)
        public
        onlyDevs()
    {
        if (MSFun.multiSig(msData, requiredDevSignatures_, "addAdmin") == true) 
        {
            MSFun.deleteProposal(msData, "addAdmin");
            if (admins_[_who].isAdmin == false) 
            { 
                admins_[_who].isAdmin = true;
                adminCount_ += 1;
                requiredSignatures_ += 1;
            }
            if (_isDev == true) 
            {
                admins_[_who].isDev = _isDev;
                devCount_ += 1;
                requiredDevSignatures_ += 1;
            }
        }
        admins_[_who].name = _name;
    }
    function removeAdmin(address _who)
        public
        onlyDevs()
    {
        require(adminCount_ > 1, "removeAdmin failed - cannot have less than 2 admins");
        require(adminCount_ >= requiredSignatures_, "removeAdmin failed - cannot have less admins than number of required signatures");
        if (admins_[_who].isDev == true)
        {
            require(devCount_ > 1, "removeAdmin failed - cannot have less than 2 devs");
            require(devCount_ >= requiredDevSignatures_, "removeAdmin failed - cannot have less devs than number of required dev signatures");
        }
        if (MSFun.multiSig(msData, requiredDevSignatures_, "removeAdmin") == true) 
        {
            MSFun.deleteProposal(msData, "removeAdmin");
            if (admins_[_who].isAdmin == true) {  
                admins_[_who].isAdmin = false;
                adminCount_ -= 1;
                if (requiredSignatures_ > 1) 
                {
                    requiredSignatures_ -= 1;
                }
            }
            if (admins_[_who].isDev == true) {
                admins_[_who].isDev = false;
                devCount_ -= 1;
                if (requiredDevSignatures_ > 1) 
                {
                    requiredDevSignatures_ -= 1;
                }
            }
        }
    }
    function changeRequiredSignatures(uint256 _howMany)
        public
        onlyDevs()
    {  
        require(_howMany > 0 && _howMany <= adminCount_, "changeRequiredSignatures failed - must be between 1 and number of admins");
        if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredSignatures") == true) 
        {
            MSFun.deleteProposal(msData, "changeRequiredSignatures");
            requiredSignatures_ = _howMany;
        }
    }
    function changeRequiredDevSignatures(uint256 _howMany)
        public
        onlyDevs()
    {  
        require(_howMany > 0 && _howMany <= devCount_, "changeRequiredDevSignatures failed - must be between 1 and number of devs");
        if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredDevSignatures") == true) 
        {
            MSFun.deleteProposal(msData, "changeRequiredDevSignatures");
            requiredDevSignatures_ = _howMany;
        }
    }
    function requiredSignatures() external view returns(uint256) {return(requiredSignatures_);}
    function requiredDevSignatures() external view returns(uint256) {return(requiredDevSignatures_);}
    function adminCount() external view returns(uint256) {return(adminCount_);}
    function devCount() external view returns(uint256) {return(devCount_);}
    function adminName(address _who) external view returns(bytes32) {return(admins_[_who].name);}
    function isAdmin(address _who) external view returns(bool) {return(admins_[_who].isAdmin);}
    function isDev(address _who) external view returns(bool) {return(admins_[_who].isDev);}
}
