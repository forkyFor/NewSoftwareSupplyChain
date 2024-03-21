// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/StructDefinitions.sol";
import "../ERC20/SupplyChainToken.sol";

contract DeveloperManager is StructDefinitions {



    //modifiers
    function checkUpdateReliability(address addr) public view{
        require(
            block.timestamp - developers[addr].last_update >= 432000,
            "Too little time has passed since the last update"
        );
    }
    
    function checkBuyReliability(address addr, uint256 reliability, uint256 max_reliability) public{
        require(
            getDeveloperID(addr) == addr,
            "You must register as a developer before you buy reliability"
        );

        require(
            !buyReliability(msg.sender, reliability, max_reliability),
            "You bought the maximum number of reliability, wait 30 days"
        );
    }

    function checkChangeAdmin(address new_admin) public view{
        require(
            getDeveloperID(new_admin) == new_admin,
            "The new admin must be a registered developer"
        );
    }

    function checkDeveloperExisting(address addr) public view{
        require(getDeveloperID(addr) != address(0), "Developer does not exist");
    }
        
    function checkDeveloperGroup(address addr) public view{
        require(
            getDeveloperID(addr) == addr,
            "You must register as a developer before you create a group"
        );
    }
    
    function checkVoteDeveloper(address addr, address developer) public view{
        require(
            getDeveloperID(addr) == addr,
            "You must register as a developer before you vote another developer"
        );
        
        require(
            getDeveloperID(developer) == developer,
            "Insert a valid developer address"
        );
        require(
            check_voted(addr, developer),
            "The developers was already voted"
        );
    }
    
    function checkRequestGroupAccess(address addr, string memory group_name) public view{
        require(
            getDeveloperID(addr) == addr,
            "You must register as a developer before you join a group"
        );
        
        require(
            check_groups_map(addr, group_name, true),
            "You are already a member of the group"
        );
        require(
            check_group_access_requests_map(addr, group_name),
            "You have already sent a request to this group"
        );
    }

    function check_groups_map_removeDeveloperFromGroup(address addr, string memory group_name) public view{
        require(
            check_groups_map(addr, group_name, false),
            "The developer is not part of the group"
        );
    }


    

    //endmodifiers

    function removeStringFromArray(
        uint256 index,
        string[] storage array
    ) internal {
        if (index >= array.length) return;

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function removeAddrFromArray(
        uint256 index,
        address[] storage array
    ) internal {
        if (index >= array.length) return;

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }


    mapping(address => Developer) public developers;

    function check_groups_map(address addr, string memory group_name, bool check) public view returns (bool){
        if (check)
            return developers[addr].groups_map[group_name] == 0;
        else
            return developers[addr].groups_map[group_name] != 0;
    }

    function check_voted(address addr, address developer) public view returns (bool){
        return developers[addr].voted[developer] == 0;
    }


    function checkDeveloperRegistered(address addr) public view returns (bool){
        require(
            getDeveloperID(addr) != addr,
            "You are already registered as a developer"
        );
    }

    function vote_developer(address addr, address developer) public{
        developers[addr].voted[developer] = block.timestamp;
    }

    function check_reported(address addr, address developer) public view returns (bool){
        return developers[addr].reported[developer] == 0;
    }

    function report_developer(address addr, address developer) public{
        
        require(
            getDeveloperID(msg.sender) == msg.sender,
            "You must register as a developer before you report another developer"
        );
        require(msg.sender != developer, "You can't report yourself");
        require(
            getDeveloperID(developer) == developer,
            "Insert a valid developer address"
        );
        require(
            check_reported(msg.sender,developer),
            "The developers was already reported"
        );
        developers[addr].reported[developer] = block.timestamp;
        setDeveloperReliability(developer, 10, false);
        developers[developer].report_num++;
    }
    

    function check_group_access_requests_map(address addr, string memory group_name) public view returns (bool){
        return developers[addr].group_access_requests_map[group_name] == 0;
    }

    // Returns the id of a developer
    function getDeveloperID(address addr) public view returns (address) {
        return developers[addr].id;
    }

    function getGroups(address addr) public view returns (string[] memory) {
        return developers[addr].groups;
    }

    function getAdminGroups(
        address addr
    ) public view returns (string[] memory) {
        return developers[addr].groups_adm;
    }

    function getGroupAccessRequests(
        address addr
    ) public view returns (string[] memory) {
        return developers[addr].group_access_requests;
    }

    function getLibraryInformationWithLevel(address addr) public returns (address){
        Developer storage curr_dev = developers[addr];
        curr_dev.interaction_points++;
        if (curr_dev.interaction_points % 1000 == 0) {
            setDeveloperReliability(
                curr_dev.id, 1,
                true
            );
            return curr_dev.id;
        }

        return address(0);
    }

    function add_group_access_requests(address addr, string memory group_name) public {
        developers[addr].group_access_requests.push(group_name);
        developers[addr].group_access_requests_map[
            group_name
        ] = developers[addr].group_access_requests.length;
    }
    
    function add_groups_map(address addr, string memory group_name) public {
        developers[addr].groups.push(group_name);
        developers[addr].groups_map[group_name] = developers[addr]
            .groups
            .length;
    }

    function setDeveloperID(address addr, address id) public {
        developers[addr].id= id;
    }

    function removeDeveloperFromGroup(address addr, string memory group_name) public{
        removeStringFromArray(
            developers[addr].groups_map[group_name] - 1,
            developers[addr].groups
        );

        developers[addr].groups_map[group_name] = 0;
    }

    function removeDeveloper(address addr) public{
        checkDeveloperExisting(addr);
        setDeveloperID(addr, address(0));
    }

    function acceptGroupRequest(string memory group_name, address addr) public{
        removeStringFromArray(
            developers[addr].group_access_requests_map[group_name] - 1,
            developers[addr].group_access_requests
        );
        developers[addr].group_access_requests_map[group_name] = 0;
    }

    function addGroupsDeveloperID(address addr, string memory group_name) public {
        developers[addr].groups.push(group_name);
        developers[addr].groups_map[group_name] = block.timestamp;
        developers[addr].groups_adm.push(group_name);
        developers[addr].groups_adm_map[group_name] = block.timestamp;
    }

    // set the id of a developer
    function newDeveloper(address addr) public {
        Developer storage dev = developers[addr];
        dev.id = addr;    
        dev.registration_date = block.timestamp;
        dev.last_update = block.timestamp;
    }

    // Returns the reliability of a developer
    function getDeveloperReliability(address addr) public view returns (uint256) {
        return developers[addr].reliability;
    }

    // set new reliability of a developer
    function setDeveloperReliability(address addr, uint256 value, bool add) public {
        if(add)
            developers[addr].reliability += value;
        else
            developers[addr].reliability -= value;
    }

    // Returns the registration date of a developer
    function getDeveloperRegistrationDate(address addr) public view returns (uint256) {
        return developers[addr].registration_date;
    }

    function getDeveloperInformation(
        address addr
    ) public  view returns (uint256, uint256) {
        return (
            getDeveloperReliability(addr),
            getDeveloperRegistrationDate(addr)  
        );
    }

    // Returns the last update date of a developer
    function getDeveloperLastUpdate(address addr) public view returns (uint256) {
        return developers[addr].last_update;
    }

    // set last update date of a developer
    function setDeveloperLastUpdate(address addr, uint256 rel) public {
        developers[addr].last_update = developers[addr].last_update + (rel * 432000);
    }

    // Returns the number of reports against a developer
    function getDeveloperReportNum(address addr) public view returns (uint256) {
        return developers[addr].report_num;
    }

    // Returns the interaction points of a developer
    function getDeveloperInteractionPoints(address addr) public view returns (uint256) {
        return developers[addr].interaction_points;
    }

    // Returns the amount of reliability bought by a developer
    function getDeveloperReliabilityBought(address addr) public view returns (uint256) {
        return developers[addr].reliability_bought;
    }

    function setDeveloperReliabilityBought(address addr, uint256 reliabilityBougth) public {
        developers[addr].reliability_bought = reliabilityBougth;
    }


    // Returns the last date when reliability was bought by a developer
    function getDeveloperLastReliabilityBuy(address addr) public view returns (uint256) {
        return developers[addr].last_reliability_buy;
    }


    function buyReliability(address addr, uint256 reliability, uint256 max_reliability) public returns (bool){
        
        if (block.timestamp - developers[addr].last_reliability_buy >= 2592000) {
            developers[addr].reliability_bought = 0;
        }
        if(developers[addr].reliability_bought + reliability < max_reliability)
            return false;

        if (developers[addr].reliability_bought == 0) {
            developers[addr].last_reliability_buy = block.timestamp;
        }

        developers[addr].reliability_bought += reliability;
        developers[addr].reliability += reliability;

        return true;

    }
}