contract IUserContract {
    event LogNewExchangeUserCreate(uint256 _KYCStatus);
    event LogNewUserCreate(uint256 _KYCStatus);
    event LogGenerationRatioUpdate(uint256 _generationRatio);
    event LogKYCStatusUpdate(uint256 _KYCStatus);
    event LogLastTransactionTimeUpdate(uint256 _lastTransactionTime);
    event LogUserPolicyUpdate(bool _termsAndConditions, bool _AML, bool _constitution, bool _CLA);
    event LogAsFounderMark();
    event LogUserBlacklistedStatusSet(bool _blacklistedStatus);
    event LogUserBan();
    event LogDailyTransactionVolumeSendingIncrease(uint256 _currentDay, uint256 _transactionVolume);
    event LogDailyTransactionVolumeReceivingIncrease(uint256 _currentDay, uint256 _transactionVolume);
    event LogWeeklyTransactionVolumeSendingIncrease(uint256 _currentWeek, uint256 _transactionVolume);
    event LogWeeklyTransactionVolumeReceivingIncrease(uint256 _currentWeek, uint256 _transactionVolume);
    event LogMonthlyTransactionVolumeSendingIncrease(uint256 _currentMonth, uint256 _transactionVolume);
    event LogMonthlyTransactionVolumeReceivingIncrease(uint256 _currentMonth, uint256 _transactionVolume);
    function initExchangeUser(uint256 _KYCStatus) external;
    function initKYCUser(uint256 _KYCStatus) external;
    function initUser(uint256 _KYCStatus) internal;
    function isValidUser() external view returns(bool);
    function getUserData() external view returns
    (
        uint256 _generationRatio, 
        uint256 _KYCStatus, 
        uint256 _lastTransactionTime, 
        bool _isBlacklistedUser,
        bool _termsAndConditionsAcceptance,
        bool _AMLAcceptance,
        bool _constitutionSign,
        bool _commonLicenseAgreementSign,
        bool _isFounder
    ); 
    function isExchangeUser() public view returns(bool);
    function updateUserPolicy(bool _termsAndConditions, bool _AML, bool _constitution, bool _CLA) external;
    function isUserPolicyAccepted() public view returns(bool);
    function updateGenerationRatio(uint256 _generationRatio) external;
    function updateKYCStatus(uint256 _newKYCStatus) external;
    function updateLastTransactionTime(uint256 _lastTransactionTime) external;
    function markAsFounder() external;
    function isFounderUser() external view returns(bool);
    function setUserBlacklistedStatus(bool _shouldBeBlacklisted) external;
    function isUserBlacklisted() external view returns(bool _isBlacklisted);
    function banUser() external;
    function isUserBanned() external view returns(bool _isBanned);
    function increaseDailyTransactionVolumeSending(uint256 _transactionVolume) external;
    function getDailyTransactionVolumeSending() external view returns(uint256 _dailyTransactionVolume);
    function increaseDailyTransactionVolumeReceiving(uint256 _transactionVolume) external;
    function getDailyTransactionVolumeReceiving() external view returns(uint256 _dailyTransactionVolume);
    function increaseWeeklyTransactionVolumeSending(uint256 _transactionVolume) external;
    function getWeeklyTransactionVolumeSending() external view returns(uint256 _weeklyTransactionVolume);
    function increaseWeeklyTransactionVolumeReceiving(uint256 _transactionVolume) external;
    function getWeeklyTransactionVolumeReceiving() external view returns(uint256 _weeklyTransactionVolume);
    function increaseMonthlyTransactionVolumeSending(uint256 _transactionVolume) external;
    function getMonthlyTransactionVolumeSending() external view returns(uint256 _monthlyTransactionVolume);
    function increaseMonthlyTransactionVolumeReceiving(uint256 _transactionVolume) external;
    function getMonthlyTransactionVolumeReceiving() external view returns(uint256 _monthlyTransactionVolume);
}
