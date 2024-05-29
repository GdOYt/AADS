contract IElectricCharger {
    function setInvestors(uint[] ids,address[] addresses,uint[] balances,uint investmentsCount);
   function getPrice() constant external returns (uint price);
}
