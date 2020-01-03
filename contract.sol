
pragma solidity >=0.5.0 < 0.6.0;

import "./ExternalStorage.sol";

contract TokenReward is ExternalStorage  {
    
    string public symbol = "5ND";
    string public tokenName = "500NgDev";
    string  public standard = "500NgDev Token v1.0";
   
    uint private membersIds = 0;
    
    uint public tokenTotalSupply;
  
    
    event NewMember(string _name, uint tagId);
    event Blacklisted(address indexed _member, string _name);
    event CNewMemeberReward(address indexed __memberToReward, uint _toId, uint _value);
    event CNewMemRewardFromMem(address indexed _from, uint _fromId, address indexed _to, uint _toId, uint _value);
    event NewRating(address indexed _ratedBy, address indexed _memberRated, uint rating);
    event Transfer(address _from, address _to, uint _memberId);
    
    address owner;
    
    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        admins[msg.sender] = true;
        balanceOf[msg.sender] = _initialSupply;
        tokenTotalSupply = _initialSupply;
    }
    
    modifier OnlyOwner() {
        require(msg.sender == owner, "Only contract owner is allowed to call this function");
        _;
    }
    
    modifier OnlyAdminOrOwner() {
        require(admins[msg.sender] == true, "Only admins or contract owner is allowed to call this function");
        _;
    }
    
    modifier IsWhitelisted(address __member) {
        require(members[__member].isWhitelisted == true, "This address is not whitelisted");
        _;
    }
   
    function addAdmin(address __newAdmin) public OnlyOwner returns(bool) {
        admins[__newAdmin] = true;
        return true;
    }
    
    function AddMember(address __member, string memory __memberName) public OnlyAdminOrOwner returns(bool) {
      members[__member].name = __memberName;
      members[__member].isWhitelisted = true;
      membersIds += 1;
       
      members[__member].memberId = membersIds;
      uint tagId = membersIds;
      
       emit NewMember(__memberName, tagId);
       return true;
    }
    
    function whiteListMember(address __member) public OnlyAdminOrOwner returns(bool) {
      members[__member].isWhitelisted = true;
       return true;
    }
    
    
    function blackListMember(address __member) public OnlyAdminOrOwner returns(bool) {
      members[__member].isWhitelisted = false;
       return true;
    }
    
    
    function isWhitelisted(address __member) view internal returns(bool) {
        return  members[__member].isWhitelisted;
    }
   
    function rateMember(address __membertorate) public IsWhitelisted(__membertorate) returns(bool) {
        uint8 ratingPoint;
        require(admins[msg.sender] || isWhitelisted(msg.sender), "You're not qualified to rate any member");
        
        if (admins[msg.sender]) {
             ratingPoint = 3;
        } 
        else if (members[__membertorate].rating == 5) {
            ratingPoint = 2;
        } else {
            ratingPoint = 1;
        }
        
         members[__membertorate].accumulatedPoints =   members[__membertorate].accumulatedPoints + ratingPoint;
        
         (uint8 __memberPoint, uint8 __starRating) = calculateReward( members[__membertorate].accumulatedPoints,  members[__membertorate].rating);
         members[__membertorate].accumulatedPoints = __memberPoint;
         members[__membertorate].rating = __starRating;
        
        emit NewRating(msg.sender, __membertorate, ratingPoint);
        return true;
    }
    
    function rewardMember() internal view OnlyAdminOrOwner returns(bool) {
            return true;
    }
    
    function calculateReward(uint8 __pointsScored, uint8 __starRating) pure internal returns(uint8, uint8) {
        if (__pointsScored < 15 ) {
            return (__pointsScored, __starRating);
        }
        uint8 __pointremained = __pointsScored % uint8(15);
        if (__starRating < 5) {
            uint8 currentStarRating = __starRating + uint8(1);
            return (__pointremained, currentStarRating);
        }
        return (__pointremained, __starRating);
    }
    
     function memberToRewardMember(address _from, address _to) internal view IsWhitelisted(_from) returns(bool)  {
        require(isWhitelisted(msg.sender));
        require(_to != address(this));
    }
    
     function cRewardMember(address __memberToReward, uint _memberId, uint256 _value) public payable OnlyAdminOrOwner returns (bool success) {
        require(_value != uint256(0));
        require(admins[__memberToReward] == false, "admins cannot be rewarded tokens");
        //require(members[__memberToReward].rating >= 3, "member do not have a proven track record");
        require(members[__memberToReward].memberId == _memberId);
        balanceOf[__memberToReward] = balanceOf[__memberToReward] + _value;
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;

        emit CNewMemeberReward( __memberToReward, _memberId, _value);
        return true;
    }
   
    function cMemberToRewardMember(address _from, uint _fromId, address _to, uint _toId, uint256 _value) public payable IsWhitelisted(_from) IsWhitelisted(_to) returns (bool success) {
        require(_value != uint256(0));
        require(isWhitelisted(msg.sender));
        require(members[_to].rating >= 1, "member must have up to 1 rating");
        require(members[_from].memberId == _fromId);
        require(members[_to].memberId == _toId);
        require(balanceOf[_from] >= _value);
        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        
        emit CNewMemRewardFromMem( _from, _fromId, _to, _toId, _value);
        return true;
    }
     
}