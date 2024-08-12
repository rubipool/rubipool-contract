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

        pools["ownership"] = 0x4352c0792b550aa2c6955B20C11f3A416078C498;
        pools["lottery"] = 0xA644f68b7fd097b7956D8Cb45F7031c64f08278D;
        pools["referral"] = 0xd3AE3c2B1B56972b473cDd4C484915D29EA71C73;
        pools["binaryPool"] = 0x218767BC1C31FbaC7c6A69D8CC1Ec42F18bfb123;
        pools["dailyProfitPool"] = 0x01edA81A3F881dc85D8abDe61141EeB15fA01F13;
        pools["oneWeekRewardPool"] = 0x10A2Ba5Fe9997112f1887D5bf372d68675fE702A;
        pools["twoWeekRewardOnePool"] = 0xb0ceAd58f004113F421BE500B2258E1F2A1b15F3;
        pools["twoWeekRewardTwoPool"] = 0xb28aAB703da342b519Ed2A64b100655BCBF0995d;

        percentages["ownership"] = 10;
        percentages["lottery"] = 5;
        percentages["referral"] = 10;
        percentages["binaryPool"] = 45;
        percentages["dailyProfitPool"] = 25;
        percentages["oneWeekRewardPool"] = 2.5;
        percentages["twoWeekRewardOnePool"] = 1.5;
        percentages["twoWeekRewardTwoPool"] = 1;
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
        uint256 oneWeekRewardPoolAmount = calculateAmount(amount, percentages["oneWeekRewardPool"]);
        uint256 twoWeekRewardOnePoolAmount = calculateAmount(amount, percentages["twoWeekRewardOnePool"]);
        uint256 twoWeekRewardTwoPoolAmount = calculateAmount(amount, percentages["twoWeekRewardTwoPool"]);

        payable(pools["ownership"]).transfer(ownershipAmount);
        payable(pools["lottery"]).transfer(lotteryAmount);
        payable(pools["referral"]).transfer(referralAmount);
        payable(pools["binaryPool"]).transfer(binaryPoolAmount);
        payable(pools["dailyProfitPool"]).transfer(dailyProfitPoolAmount);
        payable(pools["oneWeekRewardPool"]).transfer(oneWeekRewardPoolAmount);
        payable(pools["twoWeekRewardOnePool"]).transfer(twoWeekRewardOnePoolAmount);
        payable(pools["twoWeekRewardTwoPool"]).transfer(twoWeekRewardTwoPoolAmount);

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
