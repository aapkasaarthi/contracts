/*
   _____                  __  __    _
  / ___/____ _____ ______/ /_/ /_  (_)
  \__ \/ __ `/ __ `/ ___/ __/ __ \/ /
 ___/ / /_/ / /_/ / /  / /_/ / / / /
/____/\__,_/\__,_/_/   \__/_/ /_/_/

*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
// pragma experimental ABIEncoderV2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Saarthi {

    using SafeMath for uint256;

    struct Task {
        uint256 taskID;
        uint256 currentRound;
        uint256 totalRounds;
        uint256 cost;
        string[] modelHashes;
    }

    address owner;
    address coordinatorAddress = address(0xBeb71662FF9c08aFeF3866f85A6591D4aeBE6e4E);

    uint256 nextTaskID = 1;
    mapping (uint256 => Task) public SaarthiTasks;
    mapping (address => uint256[]) public UserTaskIDs;

    event newTaskCreated(uint256 indexed taskID, address indexed _user, string _modelHash, uint256 _amt, uint256 _time);
    event modelUpdated(uint256 indexed taskID, string _modelHash, uint256 _time);

    constructor() {
        owner = msg.sender;
    }

    function updateOwner(address _newOwner) public {
        require(msg.sender == owner, "Only Owner");
        owner = _newOwner;
    }

    function createTask(string memory _modelHash, uint256 _rounds) public payable {
        require(_rounds < 10, "Number of Rounds should be less than 10");
        uint256 taskCost = msg.value;

        Task memory newTask;
        newTask = Task({
            taskID: nextTaskID,
            currentRound: 1,
            totalRounds: _rounds,
            cost: taskCost,
            modelHashes: new string[](_rounds)
        });
        newTask.modelHashes[0] = _modelHash;
        SaarthiTasks[nextTaskID] = newTask;
        UserTaskIDs[msg.sender].push(nextTaskID);
        emit newTaskCreated(nextTaskID, msg.sender, _modelHash, taskCost, block.timestamp);

        nextTaskID = nextTaskID.add(1);
    }

    function updateModelForTask(uint256 _taskID,  string memory _modelHash, address payable computer) public {
        require(msg.sender == coordinatorAddress, "You are not the coordinator !");
        require(_taskID <= nextTaskID, "Invalid Task ID");
        uint256 newRound = SaarthiTasks[_taskID].currentRound.add(1);
        require(newRound <= SaarthiTasks[_taskID].totalRounds, "All Rounds Completed");


        SaarthiTasks[_taskID].currentRound = newRound;
        SaarthiTasks[_taskID].modelHashes[newRound.sub(1)] = _modelHash;
        computer.transfer(SaarthiTasks[_taskID].cost.div(SaarthiTasks[_taskID].totalRounds));
        emit modelUpdated(_taskID, _modelHash, block.timestamp);

    }

    // function getTaskHashes(uint256 _taskID) public view returns (string[] memory) {
    //     return (SaarthiTasks[_taskID].modelHashes);
    // }

    function getTaskCount() public view returns (uint256) {
        return nextTaskID.sub(1);
    }
    function getTasksOfUser() public view returns (uint256[] memory) {
        return UserTaskIDs[msg.sender];
    }

    struct Fund {
        uint256 orgID;
        string orgName;
        string fundName;
        address payable fundAddress;
        uint256 donationAmount;
        uint256 donationCnt;
    }

    uint256 public fundCnt = 0;
    uint256 public totalDonationAmount = 0;
    uint256 public totalDonationCnt = 0;
    mapping (uint256 => Fund) public Funds;

    function createFund(string memory _orgName,string memory _fundName, address payable _orgAdress) public {
        Fund memory newfund;
        newfund = Fund({
            orgID: fundCnt,
            orgName: _orgName,
            fundName: _fundName,
            fundAddress: _orgAdress,
            donationAmount:0,
            donationCnt:0
        });

        Funds[fundCnt] = newfund;
        fundCnt = fundCnt.add(1);
    }

    function donateToFund(uint256 _fundID) public payable{
        require(_fundID <= fundCnt, "Invalid Fund ID");

        Funds[_fundID].donationAmount = Funds[_fundID].donationAmount.add(msg.value);
        Funds[_fundID].donationCnt = Funds[_fundID].donationCnt.add(1);

        totalDonationAmount = totalDonationAmount.add(msg.value);
        totalDonationCnt = totalDonationCnt.add(1);

        Funds[_fundID].fundAddress.transfer(msg.value);
    }

    struct User {
        address payable userAddress;
        address[] accessors;
        uint256 recordHistoryCnt;
        string[] recordHistory;
        uint256 billAmount;
        uint256 donationCnt;
        address[] donationAddresses;
        uint256[] donationAmounts;
        bool hasCampaign;
        string campaignData;
        bool hasAllowedResearch;
    }

    mapping (address => User) public Users;
    uint256 public UserCnt = 0;

    function addUser() public {
        // already hash a history
        require(Users[msg.sender].userAddress == address(0x0), "User Already Registered");

        string[] memory newRecordHistory;
        address[] memory newAccessors;
        address[] memory newDonationAddresses;
        uint256[] memory newDonationAmounts;
        string memory newCampaignData;

        User memory userTemp = User({
            userAddress: msg.sender,
            accessors: newAccessors,
            recordHistoryCnt: 0,
            recordHistory: newRecordHistory,
            billAmount: 0,
            donationCnt: 0,
            donationAddresses: newDonationAddresses,
            donationAmounts: newDonationAmounts,
            hasCampaign: false,
            campaignData: newCampaignData,
            hasAllowedResearch: false
        });

        Users[msg.sender] = userTemp;
        UserCnt = UserCnt.add(1);

    }

    function addRecord(string memory _recordHash) public {
        // already hash a history
        if(Users[msg.sender].userAddress == address(0x0)){
            addUser();
        }

        Users[msg.sender].recordHistoryCnt = Users[msg.sender].recordHistoryCnt.add(1);
        Users[msg.sender].recordHistory.push(_recordHash);
    }

    function getRecord(address _user, uint _index) public view returns (string memory records){
        if (Users[_user].userAddress == address(0x0)){
            string memory newRecordHistory;
            return newRecordHistory;
        }

        bool allowed = false;
        for(uint256 ind=0; ind<Users[_user].accessors.length; ind = ind.add(1)){
            if (Users[_user].accessors[ind] == msg.sender){
                allowed = true;
                break;
            }
        }

        require( (Users[_user].userAddress == msg.sender) || allowed == true, "Cannot Access Records");

        return Users[_user].recordHistory[_index];

    }

    function getDonationAmounts(address _user) public view returns (uint256[] memory donationAmounts){
        require(Users[_user].userAddress != address(0x0), "Invalid User");
        return Users[_user].donationAmounts;
    }

    function getDonationAddresses(address _user) public view returns (address[] memory donationAddresses){
        require(Users[_user].userAddress != address(0x0), "Invalid User");
        return Users[_user].donationAddresses;
    }

    function allowAccessToUser(address _address) public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        Users[msg.sender].accessors.push(_address);
    }
    function allowAccessToResearch() public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        Users[msg.sender].hasAllowedResearch = true;
    }
    function revokeAccessToResearch() public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        Users[msg.sender].hasAllowedResearch = false;
    }

    function getAccessors() public view returns(address[] memory){
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");

        return Users[msg.sender].accessors;
    }

    function donateToUser(address _user) public payable{
        require(Users[_user].userAddress != address(0x0), "Invalid User");

        uint256 donationAmount = msg.value;

        Users[_user].donationCnt = Users[_user].donationCnt.add(1);
        Users[msg.sender].donationAddresses.push(msg.sender);
        Users[msg.sender].donationAmounts.push(donationAmount);

        Users[msg.sender].userAddress.transfer(donationAmount);
    }

    function billUser(uint256 _amt) public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");

        Users[msg.sender].billAmount = Users[msg.sender].billAmount.add(_amt);
    }

    address[] public Campaigns;
    mapping (address => uint256) internal CampaignsToIndex;
    uint256 public campaignCnt = 0;

    function createCampaign(string memory _campaignData) public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        require(Users[msg.sender].hasCampaign == false, "User is already Campaigning");

        Campaigns.push(msg.sender);
        CampaignsToIndex[msg.sender] = campaignCnt;
        campaignCnt = campaignCnt.add(1);
        Users[msg.sender].campaignData = _campaignData;
        Users[msg.sender].hasCampaign = true;
    }

    function stopCampaign() public {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        require(Users[msg.sender].hasCampaign == true, "User is already Campaigning");

        Users[msg.sender].hasCampaign = false;
        delete Campaigns[CampaignsToIndex[msg.sender]];
    }

    struct Report {
        address userAddress;
        string userName;
        string location;
        string file;
        string details;
    }

    Report[] public Reports;
    uint256 public reportCnt = 0;

    function fileReport(string memory _userName, string memory _location, string memory _file, string memory _details) public {

        Report memory tempreport = Report({
            userAddress:msg.sender,
            userName:_userName,
            location:_location,
            file:_file,
            details:_details
        });
        Reports.push(tempreport);
        reportCnt = reportCnt.add(1);

    }



}
