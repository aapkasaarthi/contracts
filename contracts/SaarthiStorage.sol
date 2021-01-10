/*
   _____                  __  __    _
  / ___/____ _____ ______/ /_/ /_  (_)
  \__ \/ __ `/ __ `/ ___/ __/ __ \/ /
 ___/ / /_/ / /_/ / /  / /_/ / / / /
/____/\__,_/\__,_/_/   \__/_/ /_/_/
       Saarthi Storage Layer
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;


/// @title Primary Saarthi Storage Contract
/// @author Anudit Nagar
/// @dev All function calls are currently implemented.
contract SaarthiStorage {

    uint256 public version = 0;

    address public admin;
    bool initialized;

    address public coordinatorAddress;
    bool public paused;

    //------------------------------
    // Task Coordinator
    //------------------------------

    struct Task {
        uint256 taskID;
        uint256 currentRound;
        uint256 totalRounds;
        uint256 cost;
        bytes32[] modelHashes;
    }

    uint256 public nextTaskID = 1;
    mapping (uint256 => Task) public SaarthiTasks;
    mapping (address => uint256[]) public UserTaskIDs;

    event newTaskCreated(uint256 indexed taskID, address indexed _user, bytes32 _modelHash, uint256 _amt, uint256 _time);
    event modelUpdated(uint256 indexed taskID, bytes32 _modelHash, uint256 _time);

    //------------------------------
    // Hospitals
    //------------------------------

    mapping (address => bool) public hospitals;
    mapping (address => uint256) public billAmounts;

    //------------------------------
    // Acccess Handlers
    //------------------------------

    mapping (address => mapping (address => bool)) public approval; // from -> to
    event newApproval(address indexed _from, address indexed _to, bool _finalState);

    //------------------------------
    // Public Campaigns
    //------------------------------

    address[] public Campaigns;
    uint256 public activeCampaignCnt = 0;
    mapping (address => bool) public campaignEnabled;

    event newCampaign(address indexed _campaigner, bytes32 _campaignData);
    event newCampaignDonation(address indexed _campaigner,address indexed _from, uint256 amount);
    event campaignStopped(address indexed _campaigner);

    //------------------------------
    // Crowdfunding
    //------------------------------

    uint256 public fundCnt = 0;
    uint256 public totalDonationAmount = 0;
    uint256 public totalDonationCnt = 0;
    mapping (uint256 => address payable) public Funds;

    event newFund(
        uint256 indexed _fundIndex,
        bytes32 indexed _orgName,
        bytes32 _fundName,
        address indexed _paymentReceiver
    );

    event newFundDonation(
        uint256 indexed _fundIndex,
        address indexed _sender,
        address indexed _receiver,
        uint256 _amount
    );


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


}
