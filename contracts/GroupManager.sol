// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract GroupManager {

    struct DeveloperGroup {
        string name;
        address admin;
        address[] group_developers;
        mapping(address => uint256) group_developers_map;
        address[] to_be_approved;
        mapping(address => uint256) to_be_approved_map;
        string[] group_projects;
    }

    mapping(string => DeveloperGroup) public dev_groups;



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

    //modifiers

    function checkGroupExisting(string memory group_name) public view{
        require(
            bytes(dev_groups[group_name].name).length == 0,
            "A group with the same name aready exists"
        );
    }

    function checkAcceptGroupRequest(string memory group_name, address addr, address developer) public view{
        checkNameGroup(group_name);
        require(
            dev_groups[group_name].admin == addr,
            "You must be the admin of the group to accept requests"
        );
        require(
            dev_groups[group_name].to_be_approved_map[developer] != 0,
            "This developer has not requested to join the the group"
        );
    }

    function checkNameGroup(string memory group_name) public view{
        require(
            bytes(dev_groups[group_name].name).length != 0,
            "Insert a valid group name"
        );
    }


    function checkGroupAdmin(string memory group_name, address addr) public view{
        require(
            dev_groups[group_name].admin == addr,
            "You must be the admin of the group"
        );
    }
    
    //end modifiers

    // Adds a new developer group
    function addDeveloperGroup(
        string memory group_name,
        address addr
    ) public {
        DeveloperGroup storage dev_group = dev_groups[group_name];
        dev_group.name = group_name;
        dev_group.admin = addr;
        dev_group.group_developers.push(addr);
        dev_group.group_developers_map[addr] = dev_group
            .group_developers
            .length;
    }

    function requestGroupAccess(string memory group_name, address addr) public {
        dev_groups[group_name].to_be_approved.push(addr);
        dev_groups[group_name].to_be_approved_map[addr] = dev_groups[
            group_name
        ].to_be_approved.length;
    }

    function removeDeveloperFromGroup(
        string memory group_name,
        address addr
    ) public {

        removeAddrFromArray(
            dev_groups[group_name].group_developers_map[addr] - 1,
            dev_groups[group_name].group_developers
        );
        
        dev_groups[group_name].group_developers_map[addr] = 0;
    }

    function getAdminCoeff(
        string memory group_name,
        address idDev
    ) public view returns (uint256){
        uint256 adminCoeff;
        if (dev_groups[group_name].admin == idDev) {
            adminCoeff = 2;
        } else {
            adminCoeff = 1;
        }
        return adminCoeff;
    }

        function acceptGroupRequest(string memory group_name, address addr) public{

        dev_groups[group_name].group_developers.push(addr);
        dev_groups[group_name].group_developers_map[addr] = dev_groups[
            group_name
        ].group_developers.length;
        removeAddrFromArray(
            dev_groups[group_name].to_be_approved_map[addr] - 1,
            dev_groups[group_name].to_be_approved
        );
        
        dev_groups[group_name].to_be_approved_map[addr] = 0;
    }

    // Gets the admin of the developer group
    function getGroupAdmin(string memory name) public view returns (address) {
        return dev_groups[name].admin;
    }

    // Sets the admin of the developer group
    function setGroupAdmin(string memory name, address admin) public {
        dev_groups[name].admin = admin;
    }

    // Sets the admin of the developer group
    function getGroupDevelopers(string memory name) public view returns (address[] memory) {
        return dev_groups[name].group_developers;
    }


    // Adds a developer to the group
    function addGroupDeveloper(string memory name, address developer) public {
        dev_groups[name].group_developers.push(developer);
        dev_groups[name].group_developers_map[developer] = dev_groups[name].group_developers.length - 1;
    }

    // Removes a developer from the group
    function removeGroupDeveloper(string memory name, address developer) public {
        uint256 index = dev_groups[name].group_developers_map[developer];
        address lastDeveloper = dev_groups[name].group_developers[dev_groups[name].group_developers.length - 1];
        
        dev_groups[name].group_developers[index] = lastDeveloper;
        dev_groups[name].group_developers_map[lastDeveloper] = index;
        
        dev_groups[name].group_developers.pop();
        delete dev_groups[name].group_developers_map[developer];
    }

    function getToBeApproved(
        string memory group_name
    ) public view returns (address[] memory) {
        return dev_groups[group_name].to_be_approved;
    }

    // Adds a developer to the to_be_approved list
    function addToBeApproved(string memory name, address developer) public {
        dev_groups[name].to_be_approved.push(developer);
        dev_groups[name].to_be_approved_map[developer] = dev_groups[name].to_be_approved.length - 1;
    }

    // Removes a developer from the to_be_approved list
    function removeFromToBeApproved(string memory name, address developer) public {
        uint256 index = dev_groups[name].to_be_approved_map[developer];
        address lastDeveloper = dev_groups[name].to_be_approved[dev_groups[name].to_be_approved.length - 1];
        
        dev_groups[name].to_be_approved[index] = lastDeveloper;
        dev_groups[name].to_be_approved_map[lastDeveloper] = index;
        
        dev_groups[name].to_be_approved.pop();
        delete dev_groups[name].to_be_approved_map[developer];
    }

    // Adds a project to the group
    function addGroupProject(string memory name, string memory project) public {
        dev_groups[name].group_projects.push(project);
    }

    function getGroupProjects(
        string memory group_name
    ) public view returns (string[] memory) {
        return dev_groups[group_name].group_projects;
    }


}
