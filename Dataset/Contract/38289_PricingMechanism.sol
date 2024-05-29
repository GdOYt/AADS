contract PricingMechanism is Haltable, SafeMath{
    uint public decimals;
    PriceTier[] public priceList;
    uint8 public numTiers;
    uint public currentTierIndex;
    uint public totalDepositedEthers;
    struct  PriceTier {
        uint costPerToken;
        uint ethersDepositedInTier;
        uint maxEthersInTier;
    }
    function setPricing() onlyController{
        uint factor = 10 ** decimals;
        priceList.push(PriceTier(uint(safeDiv(1 ether, 400 * factor)),0,5000 ether));
        priceList.push(PriceTier(uint(safeDiv(1 ether, 400 * factor)),0,1 ether));
        numTiers = 2;
    }
    function allocateTokensInternally(uint value) internal constant returns(uint numTokens){
        if (numTiers == 0) return 0;
        numTokens = 0;
        uint8 tierIndex = 0;
        for (uint8 i = 0; i < numTiers; i++){
            if (priceList[i].ethersDepositedInTier < priceList[i].maxEthersInTier){
                uint ethersToDepositInTier = min256(priceList[i].maxEthersInTier - priceList[i].ethersDepositedInTier, value);
                numTokens = safeAdd(numTokens, ethersToDepositInTier / priceList[i].costPerToken);
                priceList[i].ethersDepositedInTier = safeAdd(ethersToDepositInTier, priceList[i].ethersDepositedInTier);
                totalDepositedEthers = safeAdd(ethersToDepositInTier, totalDepositedEthers);
                value = safeSub(value, ethersToDepositInTier);
                if (priceList[i].ethersDepositedInTier > 0)
                    tierIndex = i;
            }
        }
        currentTierIndex = tierIndex;
        return numTokens;
    }
}
