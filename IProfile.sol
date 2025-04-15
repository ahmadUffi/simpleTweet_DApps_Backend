// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IProfile {
    struct userProfile{
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (userProfile memory);
}
