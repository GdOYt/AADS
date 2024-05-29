contract EthorseRace {
    struct chronus_info {
        bool  betting_open;  
        bool  race_start;  
        bool  race_end;  
        bool  voided_bet;  
        uint32  starting_time;  
        uint32  betting_duration;
        uint32  race_duration;  
        uint32 voided_timestamp;
    }
    address public owner;
    chronus_info public chronus;
    mapping (bytes32 => bool) public winner_horse;
    function getCoinIndex(bytes32 index, address candidate) external constant returns (uint, uint, uint, bool, uint);
}
