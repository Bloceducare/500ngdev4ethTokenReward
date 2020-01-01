pragma solidity >=0.5.0 < 0.6.0;

contract TokenReward {
    
    uint public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    
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
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed _from, address indexed _to, uint tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint tokens);
    event NewMember(string _name);
    event Blacklisted(address indexed _member, string _name);
    event NewReward(address indexed _member, uint reward);
    event NewRating(address indexed _ratedBy, address indexed _memberRated, uint rating);
    
    constructor(string memory tokenName, string memory tokenSymbol, uint initialSupply) public{
        owner = msg.sender;
        admins[msg.sender] = true;
        totalSupply = initialSupply*10**uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
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
        Member memory  memberStruct = members[__member];
        require(memberStruct.isWhitelisted == true, "This address is not whitelisted");
        _;
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
    
    function whiteListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = true;
       return true;
    }
    
    
    function blackListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = false;
       return true;
    }
    
    
    function isWhitelisted(address __member) view internal returns(bool) {
        Member memory  memberStruct = members[__member];
        return memberStruct.isWhitelisted;
    }
    
    function rateMember(address __membertorate) public IsWhitelisted(__membertorate) returns(bool) {
        Member memory __memberStruct = members[__membertorate];
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
        __memberStruct.accumulatedPoints =  __memberStruct.accumulatedPoints + ratingPoint;
        
         (uint8 __memberPoint, uint8 __starRating) = calculateReward(__memberStruct.accumulatedPoints, __memberStruct.rating);
        __memberStruct.accumulatedPoints = __memberPoint;
        __memberStruct.rating = __starRating;
        
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
        if (__pointsScored < 10 ) {
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
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0x0));
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) public returns(bool success){
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public OnlyAdminOrOwner returns(bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
        
    }
}