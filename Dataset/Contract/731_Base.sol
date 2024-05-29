contract Base {
    using SafeMath for uint256;
    address public owner;
    struct Client {
        uint256 Tokens;
        address Owner;
        uint256 Category;
        uint256[] LoansID;
    }
    struct Bank {
        uint256 Tokens;
        address Owner;
        mapping (uint256=>strCateg) Category;
        uint256[] LoansID;
        Loan[] LoanPending;
        Portfolio[] Portfolios;
    }
    struct strCateg{
        mapping(uint256=>strAmount) Amount;
    }
    struct strAmount{
        mapping(uint256=>strInsta) Installment;
    }
    struct strInsta{
        uint256 value;
        bool enable;
    }
    struct Loan{
            uint256 Debt;
            uint256 Installment;
            uint256 Id;
            uint256 ForSale;
            address Client;
            address Owner;
            uint256 Category;
            uint256 Amount;
            uint256 StartTime;
            uint256 EndTime;
    }
    struct Portfolio{
        uint256[] idLoans;
        address Owner;
        uint256 forSale;
    }
    mapping(address => Client) clients;
    mapping(address => Bank) banks;
    Loan[] loans;
    function () public payable{
        require(false, "Should not go through this point");
    }
}
