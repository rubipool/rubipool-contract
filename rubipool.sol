// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Rubipool {
    address public owner;
    address public investorWallet;
    uint256 public lastDistributionTime;

    mapping(string => address) public pools;
    mapping(string => uint256) public percentages;

    event FundsDistributed(uint256 totalAmount, uint256 timestamp);
    event WalletUpdated(string pool, address newAddress);
    event PercentageUpdated(string pool, uint256 newPercentage);
    event OwnerChanged(address newOwner);
    event InvestorWalletChanged(address newInvestorWallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address _investorWallet) {
        owner = msg.sender;
        investorWallet = _investorWallet;
        lastDistributionTime = block.timestamp;

        pools["ownership"] = 0x644E3Ab485cC974e4540b2875DB34028f3921d31;
        pools["lottery"] = 0xCB5Fad2313eB0B552640eea54E92f8A6f36b87Fe;
        pools["referral"] = 0x6b96905Ab92572a6Cc11534Bb8A833Ebd2ce9aE8;
        pools["binaryPool"] = 0x51520640693A824f3e94c78B584DE6D65B9F671a;
        pools["dailyProfitPool"] = 0x2c2015382aeBd654c5F40c1b3BecB4E89b179F90;

        percentages["ownership"] = 10;
        percentages["lottery"] = 10;
        percentages["referral"] = 10;
        percentages["binaryPool"] = 45;
        percentages["dailyProfitPool"] = 25;
    }

    receive() external payable {
        distributeFunds(msg.value);
    }

    function distributeFunds(uint256 amount) internal {
        uint256 ownershipAmount = calculateAmount(amount, percentages["ownership"]);
        uint256 lotteryAmount = calculateAmount(amount, percentages["lottery"]);
        uint256 referralAmount = calculateAmount(amount, percentages["referral"]);
        uint256 binaryPoolAmount = calculateAmount(amount, percentages["binaryPool"]);
        uint256 dailyProfitPoolAmount = calculateAmount(amount, percentages["dailyProfitPool"]);

        payable(pools["ownership"]).transfer(ownershipAmount);
        payable(pools["lottery"]).transfer(lotteryAmount);
        payable(pools["referral"]).transfer(referralAmount);
        payable(pools["binaryPool"]).transfer(binaryPoolAmount);
        payable(pools["dailyProfitPool"]).transfer(dailyProfitPoolAmount);

        emit FundsDistributed(amount, block.timestamp);
    }

    function calculateAmount(uint256 total, uint256 percentage) public pure returns (uint256) {
        return (total * percentage) / 100;
    }

    function updateWallet(string memory pool, address newAddress) public onlyOwner {
        pools[pool] = newAddress;
        emit WalletUpdated(pool, newAddress);
    }

    function updatePercentage(string memory pool, uint256 newPercentage) public onlyOwner {
        require(newPercentage <= 100, "Percentage cannot be more than 100");
        percentages[pool] = newPercentage;
        emit PercentageUpdated(pool, newPercentage);
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function changeInvestorWallet(address newInvestorWallet) public onlyOwner {
        investorWallet = newInvestorWallet;
        emit InvestorWalletChanged(newInvestorWallet);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    function getPoolAddress(string memory pool) public view returns (address) {
        return pools[pool];
    }

    function getPoolPercentage(string memory pool) public view returns (uint256) {
        return percentages[pool];
    }

    function clearPoolsToInvestor() public {
        require(block.timestamp >= lastDistributionTime + 12 hours, "Distribution time has not elapsed");

        uint256 contractBalance = address(this).balance;
        payable(investorWallet).transfer(contractBalance);

        lastDistributionTime = block.timestamp;
        emit FundsDistributed(contractBalance, block.timestamp);
    }
}
