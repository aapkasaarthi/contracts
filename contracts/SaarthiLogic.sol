/*
   _____                  __  __    _
  / ___/____ _____ ______/ /_/ /_  (_)
  \__ \/ __ `/ __ `/ ___/ __/ __ \/ /
 ___/ / /_/ / /_/ / /  / /_/ / / / /
/____/\__,_/\__,_/_/   \__/_/ /_/_/
       Saarthi Logic Layer v1
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import './SaarthiStorage.sol';

/// @title Primary Saarthi Contract
/// @author Anudit Nagar
/// @dev All function calls are currently implemented.
contract Saarthi is SaarthiStorage {

    function initialize() external {
        require(initialized == false, "Already Initialized");
        initialized = true;
        admin = msg.sender;
        coordinatorAddress = msg.sender;
    }

    modifier notPaused {
        require(
            paused == false,
            "Contract is Paused"
        );
        _;
    }

    /// @notice Updates the Admin of the Contract
    function updateAdmin(address _newAdmin) public {
        require(msg.sender == admin, "Only Admin");
        admin = _newAdmin;
    }

    /// @notice Pause the contract in case of emergency.
    function togglePause() public {
        require(msg.sender == admin, "Only Admin");
        paused = !paused;
    }

    //------------------------------
    // Task Coordinator
    //------------------------------

    /// @notice Create a new task for decentralized computation.
    /// @param _modelHash IPFS Hash of the Model.
    /// @param _rounds total number of training rounds.
    function createTask(bytes32 _modelHash, uint256 _rounds) public payable notPaused {

        Task memory newTask;
        newTask = Task({
            taskID: nextTaskID,
            currentRound: 1,
            totalRounds: _rounds,
            cost: msg.value,
            modelHashes: new bytes32[](_rounds)
        });
        newTask.modelHashes[0] = _modelHash;
        SaarthiTasks[nextTaskID] = newTask;
        UserTaskIDs[msg.sender].push(nextTaskID);
        nextTaskID = nextTaskID + 1;

        emit newTaskCreated(nextTaskID-1, msg.sender, _modelHash, msg.value, block.timestamp);

    }

    /// @notice Create a new task for decentralized computation.
    /// @param _taskID Id of the task.
    /// @param _modelHash IPFS Hash of the Model.
    /// @param computer address of the model computer.
    function updateModelForTask(uint256 _taskID,  bytes32 _modelHash, address payable computer) public notPaused {
        require(msg.sender == coordinatorAddress, "You are not the coordinator !");
        require(_taskID <= nextTaskID, "Invalid Task ID");
        uint256 newRound = SaarthiTasks[_taskID].currentRound + 1;
        require(newRound <= SaarthiTasks[_taskID].totalRounds, "All Rounds Completed");

        SaarthiTasks[_taskID].currentRound = newRound;
        SaarthiTasks[_taskID].modelHashes[newRound - 1] = _modelHash;
        computer.transfer(SaarthiTasks[_taskID].cost / SaarthiTasks[_taskID].totalRounds);
        emit modelUpdated(_taskID, _modelHash, block.timestamp);

    }

    //------------------------------
    // Hospitals
    //------------------------------

    /// @notice Toggle Hospital Access.
    /// @param _address  Address of Hospital.
    function toggleHospital(address _address) public notPaused {
        require(msg.sender == admin, "Only Admin");
        hospitals[_address] = !hospitals[_address];
    }

    /// @notice Bill a user of medical expenses.
    /// @param _user  Address of Hospital.
    /// @param _amt  Amount to bill.
    function billUser(address _user, uint256 _amt) public notPaused {
        require(hospitals[msg.sender] == true, "Unauthorized Hostpital");
        billAmounts[_user] = billAmounts[_user] + _amt;
    }

    //------------------------------
    // Acccess Handlers
    //------------------------------

    /// @notice Toggle access to records to a user.
    /// @param _address address of the user.
    function toggleAccessToAddress(address _address) public {
        approval[msg.sender][_address] = !approval[msg.sender][_address];
        emit newApproval(msg.sender, _address, approval[msg.sender][_address]);
    }

    //------------------------------
    // Public Campaigns
    //------------------------------

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
        payable(_user).transfer(msg.value);
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
