// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ProjectManager {

    struct Project {
        string name;
        address admin;
        string[] library_versions;
        mapping(string => string) library_versions_map;
        string last_version;
        string group;
    }

    mapping(string => Project) private projects;


    //modifiers
    function checkAdminProject(address addr, string memory project_name) public view{
        require(projects[project_name].admin == addr, "User did not give consent for data processing");
    }

    function checkValidProjectName(string memory project_name) public view{
        require(
            bytes(projects[project_name].name).length != 0,
            "Insert a valid project name"
        );
    }

    // Function to create or update a project
    function addProject(string memory _name, address _admin, string memory _lastVersion, string memory _group) public {
        Project storage project = projects[_name];
        project.name = _name;
        project.admin = _admin;
        project.last_version = _lastVersion;
        project.group = _group;
    }

    // Getter functions for Project
    function getProjectName(string memory _name) public view returns (string memory) {
        return projects[_name].name;
    }

    function getProjectAdmin(string memory _name) public view returns (address) {
        return projects[_name].admin;
    }

    function setProjectAdmin(string memory _name, address _admin) public {
        projects[_name].admin = _admin;
    }

    function getProjectLastVersion(string memory _name) public view returns (string memory) {
        return projects[_name].last_version;
    }

    function getProjectGroup(string memory _name) public view returns (string memory) {
        return projects[_name].group;
    }

    function checkReliabilityUser(string memory project_name,string memory CID, string memory version) public{
        projects[project_name].library_versions.push(CID);
        projects[project_name].last_version = CID;
        projects[project_name].library_versions_map[version] = CID;
    }

    // Managing library versions
    function addLibraryVersion(string memory _projectName, string memory _version, string memory _libraryCID) public {
        projects[_projectName].library_versions.push(_version);
        projects[_projectName].library_versions_map[_version] = _libraryCID;
    }

    function getLibraryVersionCID(string memory _projectName, string memory _version) public view returns (string memory) {
        return projects[_projectName].library_versions_map[_version];
    }

    function getLibraryVersions(string memory _projectName) public view returns (string[] memory) {
        return projects[_projectName].library_versions;
    }

    function createProject(
        string memory group_name,
        string memory project_name,
        address addr
    ) public returns (bool){
        if(bytes(getProjectName(project_name)).length == 0){
            return false;
        }else{
            addProject(project_name, addr, "", group_name);
            return true;
        }        
    }
}
