// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructDefinitions {
    struct Developer {
        address id;
        uint256 reliability;
        uint256 registration_date;
        uint256 last_update;
        uint256 report_num;
        uint256 interaction_points;
        uint256 reliability_bought;
        uint256 last_reliability_buy;
        string[] groups;
        mapping(string => uint256) groups_map;
        string[] groups_adm;
        mapping(string => uint256) groups_adm_map;
        string[] group_access_requests;
        mapping(string => uint256) group_access_requests_map;
        mapping(address => uint256) voted;
        mapping(address => uint256) reported;
    }

    struct DeveloperGroup {
        string name;
        address admin;
        address[] group_developers;
        mapping(address => uint256) group_developers_map;
        address[] to_be_approved;
        mapping(address => uint256) to_be_approved_map;
        string[] group_projects;
    }

    struct Project {
        string name;
        address admin;
        string[] library_versions;
        mapping(string => string) library_versions_map;
        string last_version;
        string group;
    }

    struct Library {
        string CID;
        string version;
        string project;
        uint256 reliability;
        address[] developed_by;
        string[] dependencies;
    }
}