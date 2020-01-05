pragma solidity >=0.5.0 <0.6.0;

contract TokenReward {

    string public name = "500 Nigerian Dev Token";
    string public symbol = "NDT";
    uint8 public decimals = 18;
    string public standard = "500 Nigerian Dev Token v1.0";
    uint public totalSupply;
    address owner;

    struct Member {
        string name;
        bool isWhitelisted;
        uint8 accumulatedPoints;
        uint8 rating;
    }

    mapping(address => Member) public members;
    mapping(address => bool) public admins;
    mapping(address => uint) public balances;
    mapping(address => uint) public balanceOf;
    
    event NewMember(string _name);
    event Whitelisted(address indexed _member, string _name);
    event Blacklisted(address indexed _member, string _name);
    event NewReward(address indexed _member, uint reward);
    event NewRating(address indexed _ratedBy, address indexed _memberRated, uint rating);

    modifier OnlyOwner() {
        require(msg.sender == owner, "Only contract owner is allowed to call this function");
        _;
    }
    
    modifier OnlyAdminOrOwner() {
        require(admins[msg.sender] == true, "Only admins or contract owner is allowed to call this function");
        _;
    }
    
    modifier IsWhitelisted(address __member) {
        Member memory  memberStruct = members[__member];
        require(memberStruct.isWhitelisted == true, "This address is not whitelisted");
        _;
    }                

    constructor (uint _initialSupply) public {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply; 
        owner = msg.sender;
        admins[msg.sender] = true;
    }


    function addAdmin(address __newAdmin) public OnlyOwner returns(bool) {
        admins[__newAdmin] = true;
        return true; 
    }
    
    function AddMember(address __member, string memory __memberName) public OnlyAdminOrOwner returns(bool) {
       Member memory __memberStruct;
       __memberStruct.name = __memberName;
       __memberStruct.isWhitelisted = true;
       members[__member] = __memberStruct;
     
       emit NewMember(__memberName);
       return true;
    } 
    
    function whiteListMember(address __member) public OnlyAdminOrOwner returns(bool) {
       Member storage memberStruct = members[__member];
       memberStruct.isWhitelisted = true;
       
       emit Whitelisted(__member, memberStruct.name);
       return true;
    }
    
    function blackListMember(address __member) public OnlyAdminOrOwner returns(bool) {
       Member storage memberStruct = members[__member];
       memberStruct.isWhitelisted = false;
        
       emit Blacklisted(__member, memberStruct.name);
       return true;
    }
    
    function isWhitelisted(address __member)internal view returns(bool) {
        Member memory memberStruct = members[__member];
        return memberStruct.isWhitelisted;
    }
    
    function rateMember(address __membertorate) public IsWhitelisted(__membertorate) returns(bool) {
        Member storage __memberStruct = members[__membertorate];
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
        __memberStruct.accumulatedPoints = __memberStruct.accumulatedPoints + ratingPoint;
        
         (uint8 __memberPoint, uint8 __starRating) = calculateReward(__memberStruct.accumulatedPoints, __memberStruct.rating);
        __memberStruct.accumulatedPoints = __memberPoint;
        __memberStruct.rating = __starRating;
        
        emit NewRating(msg.sender, __membertorate, ratingPoint);
        return true;
    }
    
    function rewardMember(address __memberToReward, uint8 __rewardAmount) public OnlyAdminOrOwner returns(bool) {
        require(admins[__memberToReward] == false, "admins cannot be rewarded tokens");
        require(members[__memberToReward].rating >= 3, "member do not have a proven track record");
        require(__rewardAmount <= 2, "Not more than 2 tokens can be rewarded");
        balances[__memberToReward] = balances[__memberToReward] + __rewardAmount;
        
        emit NewReward(__memberToReward, __rewardAmount);
        return true;
    }
    
    function calculateReward(uint8 __pointsScored, uint8 __starRating) internal pure returns(uint8, uint8) {
        if (__pointsScored < 10 ) {
            return (__pointsScored, __starRating);
        }
        uint8 __pointremained = __pointsScored % uint8(10);
        if (__starRating < 5) {
            uint8 currentStarRating = __starRating + uint8(1);
            return (__pointremained, currentStarRating);
        }
        return (__pointremained, __starRating);
    }
}