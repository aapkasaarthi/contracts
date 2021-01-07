/*
   _____                  __  __    _
  / ___/____ _____ ______/ /_/ /_  (_)
  \__ \/ __ `/ __ `/ ___/ __/ __ \/ /
 ___/ / /_/ / /_/ / /  / /_/ / / / /
/____/\__,_/\__,_/_/   \__/_/ /_/_/

*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

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


/// @title Primary Saarthi Contract
/// @author Anudit Nagar
/// @dev All function calls are currently implemented.
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
    bool public paused = false;

    uint256 nextTaskID = 1;
    mapping (uint256 => Task) public SaarthiTasks;
    mapping (address => uint256[]) public UserTaskIDs;

    event newTaskCreated(uint256 indexed taskID, address indexed _user, string _modelHash, uint256 _amt, uint256 _time);
    event modelUpdated(uint256 indexed taskID, string _modelHash, uint256 _time);

    constructor() {
        owner = msg.sender;
    }

    modifier notPaused {
        require(
            paused == false,
            "Contract is Paused"
        );
        _;
    }

    /// @notice Updates the Owner of the Contract
    function updateOwner(address _newOwner) public {
        require(msg.sender == owner, "Only Owner");
        owner = _newOwner;
    }

    /// @notice Pause the contract in case of emergency.
    function togglePause() public {
        require(msg.sender == owner, "Only Owner");
        paused = !paused;
    }

    /// @notice Create a new task for decentralized computation.
    /// @param _modelHash IPFS Hash of the Model.
    /// @param _rounds total number of training rounds.
    function createTask(string memory _modelHash, uint256 _rounds) public payable notPaused {
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

    /// @notice Create a new task for decentralized computation.
    /// @param _taskID Id of the task.
    /// @param _modelHash IPFS Hash of the Model.
    /// @param computer address of the model computer.
    function updateModelForTask(uint256 _taskID,  string memory _modelHash, address payable computer) public notPaused {
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


    /// @notice Get the count of all the tasks in the network.
    /// @return count
    function getTaskCount() public view returns (uint256) {
        return nextTaskID.sub(1);
    }

    /// @notice Get the task IDs of a user.
    /// @return task IDs of the user.
    function getTasksOfUser() public view returns (uint256[] memory) {
        return UserTaskIDs[msg.sender];
    }

    struct User {
        address payable userAddress;
        uint256 billAmount;
    }

    mapping (address => User) public Users;
    uint256 public UserCnt = 0;


    /// @notice Add a new user to the network.
    function addUser() public notPaused {
        // already has a history
        require(Users[msg.sender].userAddress == address(0x0), "User Already Registered");

        User memory userTemp = User({
            userAddress: payable(msg.sender),
            billAmount: 0
        });

        Users[msg.sender] = userTemp;
        UserCnt = UserCnt.add(1);

    }



    /// @notice Bill a user of medical expenses.
    /// @param _amt  Amount to bill.
    function billUser(uint256 _amt) public notPaused {
        require(Users[msg.sender].userAddress != address(0x0), "Invalid User");
        Users[msg.sender].billAmount = Users[msg.sender].billAmount.add(_amt);
    }

    //------------------------------
    // Acccess Handlers
    //------------------------------

    mapping (address => mapping (address => bool)) public approval; // from -> to
    event newApproval(address indexed _from, address indexed _to, bool _finalState);

    /// @notice Toggle access to records to a user.
    /// @param _address address of the user.
    function toggleAccessToAddress(address _address) public {
        approval[msg.sender][_address] = !approval[msg.sender][_address];
        emit newApproval(msg.sender, _address, approval[msg.sender][_address]);
    }

    //------------------------------
    // Public Campaigns
    //------------------------------

    address[] public Campaigns;
    uint256 public activeCampaignCnt = 0;
    mapping (address => bool) public campaignEnabled;

    event newCampaign(address indexed _campaigner, bytes32 _campaignData, uint256 _createdAt);
    event newCampaignDonation(address indexed _campaigner,address indexed _from, uint256 amount);

    /// @notice Create a new user campaign for donation.
    /// @param _campaignData IPFS hash of the details about a campaign.
    function startCampaign(bytes32 _campaignData) public notPaused {
        if (campaignEnabled[msg.sender] == false){
            campaignEnabled[msg.sender] = true;
            activeCampaignCnt = activeCampaignCnt + 1;
        }
        emit newCampaign(msg.sender, _campaignData, block.timestamp);
    }

    /// @notice Donate to a Campaign.
    /// @param _user Address of the Donation Receiver.
    function donateToCampaign(address _user) public payable notPaused {
        require(campaignEnabled[_user] == true, "User is not Campaigning");
        Users[msg.sender].userAddress.transfer(msg.value);
        emit newCampaignDonation(_user, msg.sender, msg.value);
    }

    /// @notice Stop a campaign
    function stopCampaign() public notPaused {
        require(campaignEnabled[msg.sender] == true, "User is not Campaigning");
        campaignEnabled[msg.sender] = false;
    }

    //------------------------------
    // Crowdfunding
    //------------------------------

    uint256 public fundCnt = 0;
    uint256 public totalDonationAmount = 0;
    uint256 public totalDonationCnt = 0;
    mapping (uint256 => address payable) public Funds;

    event newFund(
        uint256 _fundIndex,
        bytes32 indexed _orgName,
        bytes32 _fundName
    );

    event newFundDonation(
        uint256 _fundIndex,
        address indexed _sender,
        address indexed _receiver,
        uint256 _amount
    );

    /// @notice Create a new fund for donation.
    /// @param _orgName Name of Org that owns the fund.
    /// @param _fundName Name of the fund.
    /// @param _orgAdress address of the Organization.
    function createFund(bytes32 _orgName, bytes32 _fundName, address payable _orgAdress) public notPaused {

        uint256 newfundIndex = fundCnt+1;
        Funds[newfundIndex] = _orgAdress;
        fundCnt = newfundIndex;

        emit newFund(newfundIndex, _orgName, _fundName);
    }

    /// @notice Donate to a Fund of choice.
    /// @param _fundIndex ID of the Fund.
    function donateToFund(uint256 _fundIndex) public payable notPaused{
        require(_fundIndex <= fundCnt, "Invalid Fund ID");

        totalDonationAmount = totalDonationAmount + msg.value;
        totalDonationCnt = totalDonationCnt + 1;

        Funds[_fundIndex].transfer(msg.value);

        emit newFundDonation(
            _fundIndex,
            msg.sender,
            Funds[_fundIndex],
            msg.value
        );
    }

    //------------------------------
    // Reports
    //------------------------------

    uint256 public reportCnt = 0;

    event newReport(
        uint256 indexed _index,
        address indexed _reporter,
        bytes32 indexed _location,
        bytes32 _file,
        string _details,
        uint256 _time
    );

    /// @notice Create an anonymous report.
    /// @param _location lcoation of the report.
    /// @param _file IPFS hash of the report.
    /// @param _details AAdditional details about the report.
    function fileReport(bytes32 _location, bytes32 _file, string memory _details) public notPaused {

        emit newReport(
            reportCnt,
            msg.sender,
            _location,
            _file,
            _details,
            block.timestamp
        );
        reportCnt = reportCnt + 1;

    }


}
