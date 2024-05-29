contract ApcrdaZebichain is Ownable{
    mapping (uint256 =>string ) event_details; 
     DateTime public dt;
    function ApcrdaZebichain() public{
     }
     function viewMerkleHash(uint16 year, uint8 month, uint8 day)  public view returns(string hash)
     {
         uint  time = dt.toTimestamp(year,month,day);
         hash= event_details[time];
     }
     function insertHash(uint16 year, uint8 month, uint8 day, string hash) onlyOwner public{
             dt = new DateTime();
             uint  t = dt.toTimestamp(year,month,day);
             event_details[t]=hash;
       }
  }
