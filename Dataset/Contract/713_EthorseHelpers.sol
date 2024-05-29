contract EthorseHelpers {
    bytes32[] public all_horses = [bytes32("BTC"),bytes32("ETH"),bytes32("LTC")];
    mapping(address => bool) private _legitOwners;
    function _addHorse(bytes32 newHorse) internal {
        all_horses.push(newHorse);
    }
    function _addLegitOwner(address newOwner) internal
    {
        _legitOwners[newOwner] = true;
    }
    function getall_horsesCount() public view returns(uint) {
        return all_horses.length;
    }
    function _isWinnerOf(address raceAddress, address eth_address) internal view returns (bool,bytes32)
    {
        EthorseRace race = EthorseRace(raceAddress);
        BettingControllerInterface bc = BettingControllerInterface(race.owner());
        require(_legitOwners[bc.owner()]);
        bool  voided_bet;  
        bool  race_end;  
        (,,race_end,voided_bet,,,,) = race.chronus();
        if(voided_bet || !race_end)
            return (false,bytes32(0));
        bytes32 horse;
        bool found = false;
        uint256 arrayLength = all_horses.length;
        for(uint256 i = 0; i < arrayLength; i++)
        {
            if(race.winner_horse(all_horses[i])) {
                horse = all_horses[i];
                found = true;
                break;
            }
        }
        if(!found)
            return (false,bytes32(0));
        uint256 bet_amount = 0;
        if(eth_address != address(0)) {
            (,,,, bet_amount) = race.getCoinIndex(horse, eth_address);
        }
        return (bet_amount > 0, horse);
    }
}
