// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20/SupplyChainToken.sol";
import "./contracts/EventDefinitions.sol";
import "./contracts/DeveloperManager.sol";
import "./contracts/GroupManager.sol";
import "./contracts/ProjectManager.sol";
import "./contracts/ConsentManager.sol";
import "./contracts/LibraryManager.sol";


contract SoftwareSupplyChain is EventDefinitions{
    address public contract_owner;
    uint256 public devs_num;
    uint256 public groups_num;
    uint256 public projects_num;
    uint256 public libraries_num;
    uint256 public reliability_cost;

    uint256 public fees_paid;
    uint256 public total_developers_reliability;
    uint256 public total_libraries_reliability;
    uint256 public max_reliability;



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
    LibraryManager private libraryManager;
    GroupManager private groupManager;
    EventDefinitions private eventDefinitions;

    SupplyChainToken private sctContract;

    constructor(address sctAddress, uint256 max_rel, uint256 rel_cost, 
        address _developerManager,address _eventManager, address _consentManager, address _projectManager, address _libraryManager, address _groupManager) {
            developerManager = DeveloperManager(_developerManager);
            eventDefinitions = EventDefinitions(_eventManager);
            consentManager = ConsentManager(_consentManager);
            projectManager = ProjectManager(_projectManager);
            libraryManager = LibraryManager(_libraryManager);
            groupManager = GroupManager(_groupManager);
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
        developerManager.removeDeveloper(msg.sender);
        consentManager.setConsent(msg.sender,false);
        emit DeveloperRemoved(msg.sender);
    }

    function addDeveloper(string memory _email) public {
        consentManager.controlConsent(msg.sender);
        developerManager.checkDeveloperRegistered(msg.sender);
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
        developerManager.checkDeveloperGroup(msg.sender);
        require(bytes(group_name).length != 0, "The name can't be empty");
        groupManager.checkGroupExisting(group_name);
        require(
            sctContract.balanceOf(msg.sender) >= 2000,
            "You need 2000 SCT to create a group"
        );
        
        developerManager.addGroupsDeveloperID(msg.sender, group_name);
        groupManager.addDeveloperGroup(group_name, msg.sender);
        
        groups_num++;
        sctContract.transferFrom(msg.sender, address(this), 2000);
        fees_paid += 2000;
    }

    function createProject(
        string memory group_name,
        string memory project_name
    ) public  checkReliabilityUser{
        groupManager.checkNameGroup(group_name);
        require(
            bytes(project_name).length != 0,
            "The project name can't be empty"
        );
        groupManager.checkGroupAdmin(group_name, msg.sender);
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
        libraryManager.reportLibraryMalicious(_CID,msg.sender);
    }

    function getMaliciousLibraries() public view returns (string[] memory) {
        libraryManager.getMaliciousLibraries();
    }

    function resolveLibraryReport(string memory _CID, bool _isMalicious) public {
        require(groupManager.getGroupAdmin(projectManager.getProjectGroup(libraryManager.getLibraryProject(_CID))) == msg.sender, "Only admin can resolve reports");
        libraryManager.checkLibraryReport(_CID);

        address reporter = libraryManager.getLibraryMalicious(_CID);
        if (_isMalicious) {
            // Decrease the reliability of the library and encrease that of the reporter
            libraryManager.lessLibraryReliability(_CID,10);
            developerManager.setDeveloperReliability(reporter, 10, true);
            sctContract.transfer(reporter, 100); 
        } else {
            // Decrease the reliability of the developer
            developerManager.setDeveloperReliability(reporter, 10, false);
        }

        libraryManager.resolveLibraryReport(_CID);
    }

    function requestGroupAccess(string memory group_name) public checkReliabilityUser {
        consentManager.controlConsent(msg.sender);
        developerManager.checkRequestGroupAccess(msg.sender, group_name);
        groupManager.checkNameGroup(group_name);


        groupManager.requestGroupAccess(group_name, msg.sender);
        developerManager.add_group_access_requests(msg.sender, group_name);
    }

    function acceptGroupRequest(string memory group_name, address addr) public checkReliabilityUser{
        groupManager.checkAcceptGroupRequest(group_name, msg.sender, addr);


        developerManager.add_groups_map(addr, group_name);
        
        uint256 coeff;
        for (
            uint256 i = 0;
            i < groupManager.getGroupDevelopers(group_name).length;
            i++
        ) {
            address idDev = developerManager.getDeveloperID(groupManager.getGroupDevelopers(group_name)[i]);

            uint256 adminCoeff = groupManager.getAdminCoeff(group_name, idDev);

            if (developerManager.getDeveloperReliability(addr) >= (total_developers_reliability / devs_num) * 2) {
                coeff = 2 * adminCoeff;
            } else if (developerManager.getDeveloperReliability(addr) >=total_developers_reliability / devs_num) {
                coeff = 1 * adminCoeff;
            }

            developerManager.setDeveloperReliability(
                idDev,
                coeff,
                true
            );
            addReliabilityAndTokens(
                idDev,
                coeff
            );

        }

        uint256 value;
        if (
            developerManager.getDeveloperReliability(msg.sender) >=
            (total_developers_reliability / devs_num) * 2
        ) {
            value = 2;
        } else if (
            developerManager.getDeveloperReliability(msg.sender) >=
            total_developers_reliability / devs_num
        ) {
           value = 1;
        }

        developerManager.setDeveloperReliability(addr, value,true);
        addReliabilityAndTokens(addr, value);

        groupManager.acceptGroupRequest(group_name, addr);
        developerManager.acceptGroupRequest(group_name, addr);
    }

    function removeDeveloperFromGroup(
        string memory group_name,
        address addr
    ) public checkReliabilityUser{
        groupManager.checkNameGroup(group_name);
        developerManager.check_groups_map_removeDeveloperFromGroup(msg.sender, group_name);
        groupManager.checkGroupAdmin(group_name, msg.sender);

        developerManager.removeDeveloperFromGroup(addr, group_name);
        groupManager.removeDeveloperFromGroup( group_name, addr);
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
                    bytes(libraryManager.getLibraryCID(dependencies[i])).length != 0, 
                    "One of the dependencies CID is wrong"
                );
            }
        }
        require(
            !(bytes(projectManager.getLibraryVersionCID(project_name,version))
                .length !=
                0 ||
                bytes(libraryManager.getLibraryCID(CID)).length != 0),
            "The same version already exists"
        );
        require(
            sctContract.balanceOf(msg.sender) >= 1000,
            "You need 1000 SCT to add a library version to a project"
        );

        uint256 len = groupManager.getGroupDevelopers(projectManager.getProjectGroup(project_name)).length;
        uint256 rel = computeReliability(CID);
        libraryManager.addLibrary(project_name, CID, version, dependencies, rel);
        string memory projectGroup = projectManager.getProjectGroup(project_name);
        
        for (uint256 i = 0; i < len; i++) {
            libraryManager.setLibraryDevelopedBy(CID, developerManager.getDeveloperID(groupManager.getGroupDevelopers(projectGroup)[i]));
        }

        
        total_libraries_reliability += rel;
        libraries_num++;
        projectManager.checkReliabilityUser(project_name, CID, version);
        sctContract.transferFrom(msg.sender, address(this), 1000);
        fees_paid += 1000;
    }

    function voteDeveloper(address developer) public checkReliabilityUser{
        require(msg.sender != developer, "You can't vote for yourself");
        developerManager.checkVoteDeveloper(msg.sender, developer);        
        developerManager.setDeveloperReliability(developer, 10,true);
        addReliabilityAndTokens(developer, 10);
        developerManager.vote_developer(msg.sender, developer);
    }

    function reportDeveloper(address developer) public checkReliabilityUser{
        require(consentManager.getConsent(developer), "User doesn't give consent for data processing");
        developerManager.report_developer(msg.sender,developer);
        total_developers_reliability -= 10;
    }

    function updateReliability() public {
        developerManager.checkUpdateReliability(msg.sender);
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
        groupManager.checkGroupAdmin(group_name,new_admin);
        developerManager.checkChangeAdmin(new_admin);
        
        groupManager.setGroupAdmin(group_name,new_admin);
        for (
            uint256 i = 0;
            i < groupManager.getGroupProjects(group_name).length; 
            i++
        ) {
            projectManager.setProjectAdmin(projectManager.getProjectName(groupManager.getGroupProjects(group_name)[i]), new_admin);
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
        developerManager.checkBuyReliability(msg.sender, reliability, max_reliability);
        require(
            balanceOf(msg.sender) >= reliability * reliability_cost,
            "You don't have enough SCT"
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

        return developerManager.getDeveloperInformation(addr);
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
        return groupManager.getGroupProjects(group_name);
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
        return groupManager.getToBeApproved(group_name);
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
        (string memory version, string memory project, string[] memory dependencies)= libraryManager.getLibraryInformation(CID);
        reliability = computeReliability(CID);
        return (version, project, dependencies, reliability);
    }

    function getLibraryInformationWithLevel(string memory CID) public checkReliabilityUser{

        
        uint256 rel = computeReliability(CID);
        uint256 rel_diff = rel - libraryManager.getLibraryReliability(CID);
        libraryManager.setLibraryReliability(CID,rel);
        total_libraries_reliability += rel_diff;
        for (
            uint256 i = 0;
            i <
            groupManager.getGroupDevelopers(projectManager.getProjectGroup(libraryManager.getLibraryProject(CID))).length;
            i++
        ) {
            address valueReturned = developerManager.getLibraryInformationWithLevel(
                groupManager.getGroupDevelopers(projectManager.getProjectGroup(libraryManager.getLibraryProject(CID)))[i]
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
        (string memory version, string memory project, string[] memory dependencies)= libraryManager.getLibraryInformation(CID);
        emit LibraryInfo(
            version, project, dependencies,
            rel,
            level,
            reliability_mean
        );
    }

    function computeReliability(
        string memory CID
    ) private view returns (uint256) {
        address[] memory devs = libraryManager.getLibraryDevelopedBy(CID);
        uint256 len = devs.length;
        uint256 sum = 0;
        for (uint256 i = 0; i < len; i++) {
            uint256 developerReliability = developerManager.getDeveloperReliability(devs[i]);
            if (developerReliability < 0) {
                return 0;
            }
            if (
                developerManager.getDeveloperID(devs[i]) == projectManager.getProjectAdmin(libraryManager.getLibraryProject(CID))
            ) {
                sum += 2 * developerReliability;
            } else {
                sum += developerReliability;
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
