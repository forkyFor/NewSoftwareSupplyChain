// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventDefinitions {
    event LogData(string text);
    event DeveloperAdded(address indexed id, string email);
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    event verifyExistingEmail(address indexed requestId, string addressMail);
    event DeveloperRemoved(address indexed developerAddress);
    event LibraryInfo(
        string version,
        string project,
        string[] dependencies,
        uint256 reliability,
        string level,
        uint256 mean
    );
}