// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20/SupplyChainToken.sol";
import "./contracts/EventDefinitions.sol";
import "./contracts/DeveloperManager.sol";
import "./contracts/ProjectManager.sol";
import "./contracts/ConsentManager.sol";
import "./contracts/LibraryManager.sol";


contract SoftwareSupplyChain is StructDefinitions, EventDefinitions{
    address public contract_owner;
    uint256 public devs_num;
    uint256 public groups_num;
    uint256 public projects_num;
    uint256 public libraries_num;
    uint256 public reliability_cost;
    string[] public maliciousLibrariesCIDs;

    uint256 public fees_paid;
    uint256 public total_developers_reliability;
    uint256 public total_libraries_reliability;
    uint256 public max_reliability;
    
    mapping(string => DeveloperGroup) public dev_groups;
    mapping(string => Library) private libraries;
    mapping(string => address) public libraryMalicious;

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

    //modifiers
    modifier controlBalance() {
        require(
            sctContract.balanceOf(msg.sender) >= 3000,
            "You need 3000 SCT to register as a developer"
        ); 
        _;
    }

    modifier checkReliabilityUser() {
        uint256 developerReliability = developerManager.getDeveloperReliability(msg.sender);

        require(
            developerReliability >= (total_developers_reliability / devs_num),
            "You're not authorized to execute this operation"
        );
        _;
    }

    
    DeveloperManager private developerManager;
    ProjectManager private projectManager;
    ConsentManager private consentManager;
    EventDefinitions private eventDefinitions;

    SupplyChainToken private sctContract;

    constructor(address sctAddress, uint256 max_rel, uint256 rel_cost, 
        address _developerManager,address _eventManager, address _consentManager, address _projectManager) {
            developerManager = DeveloperManager(_developerManager);
            eventDefinitions = EventDefinitions(_eventManager);
            consentManager = ConsentManager(_consentManager);
            projectManager = ProjectManager(_projectManager);
            sctContract = SupplyChainToken(sctAddress);
            contract_owner = msg.sender;
            max_reliability = max_rel;
            reliability_cost = rel_cost;
    }

    // Funzione per registrare il consenso
    function registerConsent(string memory _consent) public {
        if (keccak256(abi.encodePacked(_consent)) == keccak256(abi.encodePacked("Y"))) {
            consentManager.setConsent(msg.sender,true);
        } else {
            consentManager.setConsent(msg.sender,false);
        }
    }

    // Funzione per confermare la rimozione
    function removeDeveloper() public controlBalance{
        address developersID = developerManager.getDeveloperID(msg.sender);
        require(developersID != address(0), "Developer does not exist");

        developerManager.setDeveloperID(msg.sender, address(0));
        consentManager.setConsent(msg.sender,false);
        emit DeveloperRemoved(msg.sender);
    }

    function addDeveloper(string memory _email) public {
        consentManager.controlConsent(msg.sender);
        require(
            developerManager.getDeveloperID(msg.sender) != msg.sender,
            "You are already registered as a developer"
        );
        emit verifyExistingEmail(msg.sender, _email);
    }

    function responseVerifyExistingEmail(bool found, string memory _email) public controlBalance{
        require(!found, "A developer with the same email already exists");
        require(bytes(_email).length != 0, "Insert a valid email");

        developerManager.newDeveloper(msg.sender);
        devs_num++;
        sctContract.transferFrom(msg.sender, address(this), 3000);
        fees_paid += 3000;
        emit DeveloperAdded(msg.sender, _email);
    }

    function createGroup(string memory group_name) public checkReliabilityUser{
        require(
            developerManager.getDeveloperID(msg.sender) == msg.sender,
            "You must register as a developer before you create a group"
        );
        require(bytes(group_name).length != 0, "The name can't be empty");
        require(
            bytes(dev_groups[group_name].name).length == 0,
            "A group with the same name aready exists"
        );
        require(
            sctContract.balanceOf(msg.sender) >= 2000,
            "You need 2000 SCT to create a group"
        );
        DeveloperGroup storage dev_group = dev_groups[group_name];
        developerManager.addGroupsDeveloperID(msg.sender, group_name);
        dev_group.name = group_name;
        dev_group.admin = msg.sender;
        dev_group.group_developers.push(msg.sender);
        dev_group.group_developers_map[msg.sender] = dev_group
            .group_developers
            .length;
        groups_num++;
        sctContract.transferFrom(msg.sender, address(this), 2000);
        fees_paid += 2000;
    }

    function createProject(
        string memory group_name,
        string memory project_name
    ) public  checkReliabilityUser{
        require(
            bytes(dev_groups[group_name].name).length != 0,
            "Insert a valid group name"
        );
        require(
            bytes(project_name).length != 0,
            "The project name can't be empty"
        );
        require(
            dev_groups[group_name].admin == msg.sender,
            "You must be the admin of the group to create a project"
        );
        require(
            sctContract.balanceOf(msg.sender) >= 2000,
            "You need 2000 SCT to create a project"
        );
        if(projectManager.createProject(group_name,project_name,msg.sender)){
            projects_num++;
            sctContract.transferFrom(msg.sender, address(this), 2000);
            fees_paid += 2000;
        }        
    }

    function reportLibraryMalicious(string memory _CID) public {
        require(bytes(libraries[_CID].CID).length != 0, "Library does not exist");
        require(libraryMalicious[_CID] == address(0), "Library already reported");

        libraryMalicious[_CID] = msg.sender;
        maliciousLibrariesCIDs.push(_CID); 
    }

    function getMaliciousLibraries() public view returns (string[] memory) {
        return maliciousLibrariesCIDs;
    }

    function resolveLibraryReport(string memory _CID, bool _isMalicious) public {
    require(dev_groups[projectManager.getProjectGroup(libraries[_CID].project)].admin == msg.sender, "Only admin can resolve reports");
    require(libraryMalicious[_CID] != address(0), "Library not reported");

        address reporter = libraryMalicious[_CID];
        if (_isMalicious) {
            // Decrease the reliability of the library and encrease that of the reporter
            libraries[_CID].reliability -= 10;
            developerManager.setDeveloperReliability(reporter, 10, true);
            sctContract.transfer(reporter, 100); 
        } else {
            // Decrease the reliability of the developer
            developerManager.setDeveloperReliability(reporter, 10, false);
        }

        // remove libraries
        libraryMalicious[_CID] = address(0);

        int256 index = -1;
        for (uint256 i = 0; i < maliciousLibrariesCIDs.length; i++) {
            if (keccak256(abi.encodePacked(maliciousLibrariesCIDs[i])) == keccak256(abi.encodePacked(_CID))) {
                index = int256(i);
                break;
            }
        }
        maliciousLibrariesCIDs[uint256(index)] = maliciousLibrariesCIDs[maliciousLibrariesCIDs.length - 1];
        maliciousLibrariesCIDs.pop();
    }

    function requestGroupAccess(string memory group_name) public checkReliabilityUser {
        consentManager.controlConsent(msg.sender);
        require(
            developerManager.getDeveloperID(msg.sender) == msg.sender,
            "You must register as a developer before you join a group"
        );
        
        require(
            developerManager.check_groups_map(msg.sender, group_name, true),
            "You are already a member of the group"
        );
        require(
            developerManager.check_group_access_requests_map(msg.sender, group_name),
            "You have already sent a request to this group"
        );
        require(
            bytes(dev_groups[group_name].name).length != 0,
            "Insert a valid group name"
        );
        dev_groups[group_name].to_be_approved.push(msg.sender);
        dev_groups[group_name].to_be_approved_map[msg.sender] = dev_groups[
            group_name
        ].to_be_approved.length;
        developerManager.add_group_access_requests(msg.sender, group_name);
    }

    function acceptGroupRequest(string memory group_name, address addr) public checkReliabilityUser{
        require(
            bytes(dev_groups[group_name].name).length != 0,
            "Insert a valid group name"
        );
        require(
            dev_groups[group_name].admin == msg.sender,
            "You must be the admin of the group to accept requests"
        );
        require(
            dev_groups[group_name].to_be_approved_map[addr] != 0,
            "This developer has not requested to join the the group"
        );
        developerManager.add_groups(addr, group_name);
        developerManager.add_groups_map(addr, group_name);
        uint256 adminCoeff;
        for (
            uint256 i = 0;
            i < dev_groups[group_name].group_developers.length;
            i++
        ) {
            if (
                dev_groups[group_name].admin == developerManager.getDeveloperID(dev_groups[group_name].group_developers[i])
            ) {
                adminCoeff = 2;
            } else {
                adminCoeff = 1;
            }
            if (
                developerManager.getDeveloperReliability(addr) >=
                (total_developers_reliability / devs_num) * 2
            ) {
                developerManager.setDeveloperReliability(
                    developerManager.getDeveloperID(dev_groups[group_name].group_developers[i]),
                    2 * adminCoeff,
                    true
                );
                addReliabilityAndTokens(
                    developerManager.getDeveloperID(dev_groups[group_name].group_developers[i]),
                    2 * adminCoeff
                );
            } else if (
                developerManager.getDeveloperReliability(addr) >=
                total_developers_reliability / devs_num
            ) {
                developerManager.setDeveloperReliability(
                    developerManager.getDeveloperID(dev_groups[group_name].group_developers[i]),
                    1 * adminCoeff,
                    true
                );
                addReliabilityAndTokens(
                    developerManager.getDeveloperID(dev_groups[group_name].group_developers[i]),
                    1 * adminCoeff
                );
            }
        }
        if (
            developerManager.getDeveloperReliability(msg.sender) >=
            (total_developers_reliability / devs_num) * 2
        ) {
            developerManager.setDeveloperReliability(
                    addr, 2,
                    true
                );
            addReliabilityAndTokens(addr, 2);
        } else if (
            developerManager.getDeveloperReliability(msg.sender) >=
            total_developers_reliability / devs_num
        ) {
            developerManager.setDeveloperReliability(
                    addr, 1,
                    true
                );
            addReliabilityAndTokens(addr, 1);
        }
        dev_groups[group_name].group_developers.push(addr);
        dev_groups[group_name].group_developers_map[addr] = dev_groups[
            group_name
        ].group_developers.length;
        removeAddrFromArray(
            dev_groups[group_name].to_be_approved_map[addr] - 1,
            dev_groups[group_name].to_be_approved
        );
        
        dev_groups[group_name].to_be_approved_map[addr] = 0;
        developerManager.acceptGroupRequest(group_name, addr);
    }

    function removeDeveloperFromGroup(
        string memory group_name,
        address addr
    ) public checkReliabilityUser{
        require(
            bytes(dev_groups[group_name].name).length != 0,
            "Insert a valid group name"
        );
        require(
            developerManager.check_groups_map(msg.sender, group_name, false),
            "The developer is not part of the group"
        );
        require(
            dev_groups[group_name].admin == msg.sender,
            "You must be the admin of the group to remove a developer from it"
        );

        developerManager.removeDeveloperFromGroup(addr, group_name);
        removeAddrFromArray(
            dev_groups[group_name].group_developers_map[addr] - 1,
            dev_groups[group_name].group_developers
        );
        
        dev_groups[group_name].group_developers_map[addr] = 0;
    }

    function addLibrary(
        string memory project_name,
        string memory CID,
        string memory version,
        string[] memory dependencies
    ) public checkReliabilityUser{
        projectManager.checkAdminProject(msg.sender, project_name);
        projectManager.checkValidProjectName(project_name);
        require(bytes(CID).length != 0, "The CID can't be empty");

        if (bytes(dependencies[0]).length != 0) {
            for (uint256 i = 0; i < dependencies.length; i++) {
                require(
                    bytes(libraries[dependencies[i]].CID).length != 0,
                    "One of the dependencies CID is wrong"
                );
            }
        }
        require(
            !(bytes(projectManager.getLibraryVersionCID(project_name,version))
                .length !=
                0 ||
                bytes(libraries[CID].CID).length != 0),
            "The same version already exists"
        );
        require(
            sctContract.balanceOf(msg.sender) >= 1000,
            "You need 1000 SCT to add a library version to a project"
        );
        Library storage lib = libraries[CID];
        lib.CID = CID;
        lib.version = version;
        lib.dependencies = dependencies;
        lib.project = project_name;

        uint256 len = dev_groups[projectManager.getProjectGroup(project_name)]
                    .group_developers.length;
        for (uint256 i = 0; i < len; i++) {
            lib.developed_by.push(developerManager.getDeveloperID( 
                dev_groups[projectManager.getProjectGroup(project_name)]
                    .group_developers[i]
            ));
        }

        uint256 rel = computeReliability(CID);
        lib.reliability = rel;
        total_libraries_reliability += rel;
        libraries_num++;
        projectManager.checkReliabilityUser(project_name, CID, version);
        sctContract.transferFrom(msg.sender, address(this), 1000);
        fees_paid += 1000;
    }

    function voteDeveloper(address developer) public checkReliabilityUser{
        require(
            developerManager.getDeveloperID(msg.sender) == msg.sender,
            "You must register as a developer before you vote another developer"
        );
        require(msg.sender != developer, "You can't vote for yourself");
        require(
            developerManager.getDeveloperID(developer) == developer,
            "Insert a valid developer address"
        );
        require(
            developerManager.check_voted(msg.sender, developer),
            "The developers was already voted"
        );
        developerManager.setDeveloperReliability(
                    developer, 10,
                    true
                );
        addReliabilityAndTokens(developer, 10);
        developerManager.vote_developer(msg.sender, developer);
    }

    function reportDeveloper(address developer) public checkReliabilityUser{
        require(consentManager.getConsent(developer), "User doesn't give consent for data processing");
        developerManager.report_developer(msg.sender,developer);
        total_developers_reliability -= 10;
    }

    function updateReliability() public {
        require(
            developerManager.check_last_update(msg.sender),
            "Too little time has passed since the last update"
        );
        uint256 time = block.timestamp - developerManager.getDeveloperLastUpdate(msg.sender);
        uint256 rel = time / 432000;
        developerManager.setDeveloperReliability(
                    msg.sender, rel,
                    true
                );
        addReliabilityAndTokens(msg.sender, rel);
        developerManager.setDeveloperLastUpdate(msg.sender, rel);
    }

    function changeAdmin(address new_admin, string memory group_name) public checkReliabilityUser{
        require(
            dev_groups[group_name].admin == msg.sender,
            "You must be the admin of the group to appoint another admin in your place"
        );
        require(
            developerManager.getDeveloperID(new_admin) == new_admin,
            "The new admin must be a registered developer"
        );
        dev_groups[group_name].admin = new_admin;
        for (
            uint256 i = 0;
            i < dev_groups[group_name].group_projects.length;
            i++
        ) {
            projectManager.setProjectAdmin(projectManager.getProjectName(dev_groups[group_name].group_projects[i]), new_admin);
        }
    }

    function buyTokens() public payable {
        uint256 tokens = msg.value * 1;
        require(tokens > 0, "You need to send some ether");
        require(
            tokens <= sctContract.balanceOf(address(this)),
            "Not enough tokens in the reserve"
        );
        sctContract.transfer(msg.sender, tokens);
        emit Bought(tokens);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = sctContract.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        sctContract.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

    function buyReliability(uint256 reliability) public {
        require(
            developerManager.getDeveloperID(msg.sender) == msg.sender,
            "You must register as a developer before you buy reliability"
        );
        require(
            balanceOf(msg.sender) >= reliability * reliability_cost,
            "You don't have enough SCT"
        );
        
        require(
            !developerManager.buyReliability(msg.sender, reliability, max_reliability),
            "You bought the maximum number of reliability, wait 30 days"
        );
        
        sctContract.transferFrom(
            msg.sender,
            address(this),
            reliability * reliability_cost
        );
        
        total_developers_reliability += reliability;
        fees_paid += reliability * reliability_cost;
    }

    function balanceOf(address token_owner) public view returns (uint256) {
        return sctContract.balanceOf(token_owner);
    }

    function getDeveloperInformation(
        address addr
    ) public  checkReliabilityUser view returns (uint256, uint256) {
        consentManager.controlConsent(addr);
        return (
            developerManager.getDeveloperReliability(addr),
            developerManager.getDeveloperRegistrationDate(addr)  
        );
    }

    function getGroups(address addr) public checkReliabilityUser view returns (string[] memory) {
        return developerManager.getGroups(addr);
    }

    function getAdminGroups(
        address addr
    ) public checkReliabilityUser view returns (string[] memory) {
        consentManager.controlConsent(addr);
        return developerManager.getAdminGroups(addr);
    }

    function getGroupProjects(
        string memory group_name
    ) public checkReliabilityUser view returns (string[] memory) {
        return dev_groups[group_name].group_projects;
    }

    function getGroupAccessRequests(
        address addr
    ) public checkReliabilityUser view returns (string[] memory) {
        consentManager.controlConsent(addr);
        return developerManager.getGroupAccessRequests(addr);
    }

    function getToBeApproved(
        string memory group_name
    ) public checkReliabilityUser view returns (address[] memory) {
        return dev_groups[group_name].to_be_approved;
    }

    function getProjectVersions(
        string memory project_name
    ) public view returns (string[] memory) {
        projectManager.getLibraryVersions(project_name);
    }

    function getProjectLastVersion(
        string memory project_name
    ) public view returns (string memory) {
        projectManager.getProjectLastVersion(project_name);
    }

    function getLibraryInformation(
        string memory CID
    )
        public checkReliabilityUser
        view
        returns (
            string memory,
            string memory,
            string[] memory,
            uint256 reliability
        )
    {
        return (
            libraries[CID].version,
            libraries[CID].project,
            libraries[CID].dependencies,
            computeReliability(CID)
        );
    }

    function getLibraryInformationWithLevel(string memory CID) public checkReliabilityUser{

        
        uint256 rel = computeReliability(CID);
        uint256 rel_diff = rel - libraries[CID].reliability;
        libraries[CID].reliability = rel;
        total_libraries_reliability += rel_diff;
        for (
            uint256 i = 0;
            i <
            dev_groups[projectManager.getProjectGroup(libraries[CID].project)]
                .group_developers
                .length;
            i++
        ) {
            address valueReturned = developerManager.getLibraryInformationWithLevel(
                dev_groups[projectManager.getProjectGroup(libraries[CID].project)]
                    .group_developers[i]
            );
            if(valueReturned != address(0)){
                addReliabilityAndTokens(valueReturned, 1);
            }
        }
        string memory level;
        uint256 reliability_mean = total_libraries_reliability / libraries_num;
        if (rel <= (reliability_mean * 1) / 3) {
            level = "Very Low";
        } else if (rel <= (reliability_mean * 2) / 3) {
            level = "Low";
        } else if (rel <= (reliability_mean * 3) / 2) {
            level = "Medium";
        } else if (rel <= (reliability_mean * 2)) {
            level = "High";
        } else {
            level = "Very High";
        }
        emit LibraryInfo(
            libraries[CID].version,
            libraries[CID].project,
            libraries[CID].dependencies,
            rel,
            level,
            reliability_mean
        );
    }

    function computeReliability(
        string memory CID
    ) private view returns (uint256) {
        address[] memory devs = libraries[CID].developed_by;
        uint256 len = devs.length;
        uint256 sum = 0;
        for (uint256 i = 0; i < len; i++) {
            if (developerManager.getDeveloperReliability(devs[i]) < 0) {
                return 0;
            }
            if (
                developerManager.getDeveloperID(devs[i]) == projectManager.getProjectAdmin(libraries[CID].project)
            ) {
                sum += 2 * developerManager.getDeveloperReliability(devs[i]);
            } else {
                sum += developerManager.getDeveloperReliability(devs[i]);
            }
        }

        return sum / len;
    }


    function addReliabilityAndTokens(address dev, uint256 reliability) private {
        total_developers_reliability += reliability;
        if (fees_paid >= reliability) {
            sctContract.transfer(dev, reliability);
            fees_paid -= reliability;
        }
    }
}
