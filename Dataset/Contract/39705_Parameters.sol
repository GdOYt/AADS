contract Parameters {
  uint public constant round0StartTime      = 1484676000; 
  uint public constant round1StartTime      = 1495040400; 
  uint public constant round0EndTime        = round0StartTime + 6 weeks;
  uint public constant round1EndTime        = round1StartTime + 6 weeks;
  uint public constant finalizeStartTime    = round1EndTime   + 1 weeks;
  uint public constant finalizeEndTime      = finalizeStartTime + 1000 years;
  uint public constant maxRoundDelay     = 270 days;
  uint public constant gracePeriodAfterRound0Target  = 1 days;
  uint public constant gracePeriodAfterRound1Target  = 0 days;
  uint public constant tokensPerCHF = 10; 
  uint public constant minDonation = 1 ether; 
  uint public constant round0Bonus = 200; 
  uint public constant round1InitialBonus = 25;
  uint public constant round1BonusSteps = 5;
  uint public constant millionInCents = 10**6 * 100;
  uint public constant round0Target = 1 * millionInCents; 
  uint public constant round1Target = 20 * millionInCents;
  uint public constant earlyContribShare = 22; 
}
