/*
   _____                  __  __    _
  / ___/____ _____ ______/ /_/ /_  (_)
  \__ \/ __ `/ __ `/ ___/ __/ __ \/ /
 ___/ / /_/ / /_/ / /  / /_/ / / / /
/____/\__,_/\__,_/_/   \__/_/ /_/_/
           Proxy Contract
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import './SaarthiStorage.sol';

contract Registry is SaarthiStorage {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public logic_contract;

    // admin to set contract
    function setLogicContract(address _c) public onlyOwner returns (bool success){
        logic_contract = _c;
        version = version + 1;
        return true;
    }

    // fallback function
    fallback() payable external {

        address target = logic_contract;

        assembly {
            // Copy the data sent to the memory address starting free mem position
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Proxy the call to the contract address with the provided gas and data
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)

            // Copy the data returned by the proxied call to memory
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            // Check what the result is, return and revert accordingly
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {
        // custom function code
    }

}
