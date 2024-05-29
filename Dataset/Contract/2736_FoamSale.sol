contract FoamSale is Sale {
    address private constant FOAM_WALLET = 0x3061CFBAe69Bff0f933353cea20de6C89Ab16acc;
    constructor() 
        Sale(
            24000000,  
            90,  
            1,  
            1000000000 * (10 ** 18),  
            0x8dAB5379f7979df2Fac963c69B66a25AcdaADbB7,  
            FOAM_WALLET,  
            1 ether,  
            25000 ether,  
            0,  
            1532803878,  
            "FOAM Token",  
            "FOAM",  
            18,  
            EthPriceFeedI(0x54bF24e1070784D7F0760095932b47CE55eb3A91)  
        )
        public 
    {
        setupDisbursement(FOAM_WALLET, 700000000 * (10 ** 18), 1 hours);
    }
}
