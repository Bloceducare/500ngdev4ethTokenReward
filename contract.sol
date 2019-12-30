pragma solidity >=0.5.0 < 0.6.0;
contract TokenReward {
    
    struct Member {
        string name;
        bool isWhitelisted;
        uint8 accumulatedPoints;
        uint8 rating;
    }
    //Mappings
    address owner;//Our state variable
    mapping(address => Member) public members;//each Member has an address
    mapping(address => uint ) public reward;//captures the reward in uint of each address
    mapping(address => bool ) public admins;//captures the addresses that are admins or not
    mapping(address => uint ) public balances;//captures the balances in uint of each address
    //Events
    event NewMember(string _name);//Trigers when a new name is added
    event Whitelisted(address indexed _member, string _name);
    event Blacklisted(address indexed _member, string _name);//trigers new blacklisting
    event NewReward(address indexed _member, uint reward);//trigers new reward and the member
    event NewRating(address indexed _ratedBy, address indexed _memberRated, uint rating);//trigers new rating
    //Modifiers
    modifier OnlyOwner() {
        require(msg.sender == owner, "Only contract owner is allowed to call this function");
        _;//This allows only the owner to make changes
    }
    
    modifier OnlyAdminOrOwner() {
        require(admins[msg.sender] == true, "Only admins or contract owner is allowed to call this function");
        _;//This allows only admin or owner to make changes
    }
    
    modifier IsWhitelisted(address __member) {
        Member memory  memberStruct = members[__member];//Any member that is whitelisted is now called memberStruct
        require(memberStruct.isWhitelisted == true, "This address is not whitelisted");
        _;//This allows only whitelisted member to make changes
    }                
    
    constructor () public {//Only the owner of the contract will call this
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    //This function helps to add a new Admin and can be called only by the owner
    function addAdmin(address __newAdmin) public OnlyOwner returns(bool) {
        admins[__newAdmin] = true;
        return true; 
    }
    
    //This adds a new member and can be called only by admins and the owner
    function AddMember(address __member, string memory __memberName) public OnlyAdminOrOwner returns(bool) {
       Member memory __memberStruct;
       __memberStruct.name = __memberName;
       __memberStruct.isWhitelisted = true;
       members[__member] = __memberStruct;
       
       emit NewMember(__memberName);
       return true;
    } 
    //This function whitelist a member and can be called only by admins and the owner
    function whiteListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member storage  memberStruct = members[__member];
       memberStruct.isWhitelisted = true;
       
       emit Whitelisted(__member, memberStruct.name);
       return true;
    }
    

   //This function blcacklist a member and can be called only by admins and the owner
    function blackListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member storage  memberStruct = members[__member];
       memberStruct.isWhitelisted = false;
        
       emit Blacklisted(__member, memberStruct.name);
       return true;
    }
    
   // This function checks if a member is whitelisted or not
    function isWhitelisted(address __member)internal view returns(bool) {
        Member memory  memberStruct = members[__member];
        return memberStruct.isWhitelisted;
    }
    //This function rate a member and can be called by admins,owners,and whitelisted members
    function rateMember(address __membertorate) public OnlyAdminOrOwner IsWhitelisted(__membertorate) returns(bool) {
        Member storage __memberStruct = members[__membertorate];
        uint8 ratingPoint;
        require(admins[msg.sender] || isWhitelisted(msg.sender), "You're not qualified to rate any member");
        if (admins[msg.sender]) {
            ratingPoint = 3;
        } 
        if (members[__membertorate].rating == 5) { 
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
    //This function rewards members
    function rewardMember(address __memberToReward) public OnlyAdminOrOwner returns(bool) {
        require(admins[__memberToReward] == false, "admins cannot be rewarded tokens");
        require(members[__memberToReward].rating >= 3, "member do not have a proven track record");
        balances[__memberToReward] = balances[__memberToReward] + 2;
        return true;
    }
    //This function helps calculate the members' reward base on point scored and star rating
    function calculateReward(uint8 __pointsScored, uint8 __starRating) internal pure returns(uint8, uint8) {
        if (__pointsScored < 10 ) {
            return (__pointsScored, __starRating);
        }
        uint8 __pointremained = __pointsScored % uint8(15);
        if (__starRating < 5) {
            uint8 currentStarRating = __starRating + uint8(1);
            return (__pointremained, currentStarRating);
        }
        return (__pointremained, __starRating);
    }
}