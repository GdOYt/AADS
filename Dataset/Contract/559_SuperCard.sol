contract SuperCard is SPCevents {
    using SafeMath for *;
    using NameFilter for string;
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xbac825cdb506dcf917a7715a4bf3fa1b06abe3e4);
    address private admin = msg.sender;
    string constant public name   = "SuperCard";
    string constant public symbol = "SPC";
    uint256 private rndExtra_     = 0;     
    uint256 private rndGap_ = 2 minutes;         
    uint256 constant private rndInit_ = 6 hours;           
    uint256 constant private rndInc_ = 30 seconds;              
    uint256 constant private rndMax_ = 24 hours;                
    uint256 public airDropPot_;             
    uint256 public airDropTracker_ = 0;     
    uint256 public rID_;    
    uint256 public pID_;    
/
  }
