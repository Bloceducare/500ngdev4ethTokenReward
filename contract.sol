pragma solidity >=0.5.0 < 0.6.0;
contract TokenReward {
    struct Member {
        uint8 rating;
        string name;
        bool isWhitelisted;
        uint8 accumulatedPoints;
    }
    
    address owner;
    mapping(address => Member) public members;
    mapping(address => uint ) public reward;
    mapping(address => bool ) public admins;
    mapping(address => uint ) public balances;
    
    event NewMember(string _name);
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
        require(members[__member].isWhitelisted == true, "This address is not whitelisted");
        _;
    }
    
    constructor () public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }
    
    function addAdmin(address __newAdmin) public OnlyOwner returns(bool) {
        admins[__newAdmin] = true;
        return true;
    }
    
    
    function AddMember(address __member, string memory __memberName) public OnlyAdminOrOwner returns(bool) {
      members[__member].name = __memberName;
      members[__member].isWhitelisted = true;
       
       
       emit NewMember(__memberName);
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
    
    function rateMember(address __membertorate) public  returns(bool) {
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
    
    function rewardMember(address __memberToReward) public OnlyAdminOrOwner returns(bool) {
        require(admins[__memberToReward] == false, "admins cannot be rewarded tokens");
        require(members[__memberToReward].rating >= 3, "member do not have a proven track record");
        balances[__memberToReward] = balances[__memberToReward] + 2;
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
        return (__pointremained, __starRating
        );
    }
}