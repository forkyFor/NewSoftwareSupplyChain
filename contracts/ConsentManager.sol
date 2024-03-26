// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20/SupplyChainToken.sol";

contract ConsentManager {


    mapping(address => bool) public consentGiven;

    function controlConsent(address addr) public view{
        require(consentGiven[addr], "User did not give consent for data processing");
    }


    // Returns the id of a developer
    function getConsent(address addr) public view returns (bool) {
        return consentGiven[addr];
    }

    // set new reliability of a developer
    function setConsent(address addr, bool value) public {
        consentGiven[addr] = value;
    }

   
}