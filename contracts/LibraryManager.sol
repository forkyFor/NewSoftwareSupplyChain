// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/StructDefinitions.sol";
import "../ERC20/SupplyChainToken.sol";

contract LibraryManager is StructDefinitions {
    
    mapping(string => Library) public libraries;
    mapping(string => address) public libraryMalicious;
    string[] public maliciousLibrariesCIDs;


    // Getter functions for Library attributes
    function getLibraryCID(string memory _CID) public view returns (string memory) {
        return libraries[_CID].CID;
    }

    function getLibraryVersion(string memory _CID) public view returns (string memory) {
        return libraries[_CID].version;
    }

    function getLibraryProject(string memory _CID) public view returns (string memory) {
        return libraries[_CID].project;
    }

    function getLibraryReliability(string memory _CID) public view returns (uint256) {
        return libraries[_CID].reliability;
    }

    function setLibraryReliability(string memory _CID, uint256 rel) public {
        libraries[_CID].reliability = rel;
    }

    
    function lessLibraryReliability(string memory _CID, uint256 rel) public {
        libraries[_CID].reliability -= rel;
    }

    function addLibrary(
        string memory project_name,
        string memory CID,
        string memory version,
        string[] memory dependencies,
        uint256 rel
    ) public {
        libraries[CID].CID = CID;
        libraries[CID].version = version;
        libraries[CID].dependencies = dependencies;
        libraries[CID].project = project_name;
        libraries[CID].reliability = rel;
    }

    function getLibraryInformation(string memory _CID) public view returns (string memory,string memory,string[] memory) {
        return (
            libraries[_CID].version,
            libraries[_CID].project,
            libraries[_CID].dependencies
        );
    }

    function getLibraryDevelopedBy(string memory _CID) public view returns (address[] memory) {
        return libraries[_CID].developed_by;
    }

    
    function getLibraryMalicious(string memory _CID) public view returns (address) {
        return libraryMalicious[_CID];
    }

    function resolveLibraryReport(string memory _CID) public {

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

    function setLibraryDevelopedBy(string memory _CID, address developer) public {
        libraries[_CID].developed_by.push(developer);
    }

    function getLibraryDependencies(string memory _CID) public view returns (string[] memory) {
        return libraries[_CID].dependencies;
    }

    // Handling malicious library reports
    function reportLibraryMalicious(string memory _CID, address addr) public {
        require(bytes(libraries[_CID].CID).length != 0, "Library does not exist");
        require(libraryMalicious[_CID] == address(0), "Library already reported");

        libraryMalicious[_CID] = addr;
        maliciousLibrariesCIDs.push(_CID); 
    }

    function getMaliciousLibraries() public view returns (string[] memory) {
        return maliciousLibrariesCIDs;
    }

    // Function to check if a library report exists
    function checkLibraryReport(string memory _CID) public view{
        require(libraryMalicious[_CID] != address(0), "Library not reported");
    }
}
