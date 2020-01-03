pragma solidity >=0.5.0 < 0.6.0;

contract ExternalStorage {
    
    mapping(address => Member) public members;
    mapping(address => bool ) public admins;
    mapping(address => uint ) public balanceOf;
    
     struct Member {
        string name;
        bool isWhitelisted;
        uint8 rating;
        uint8 accumulatedPoints;
        uint memberId;
    }
}