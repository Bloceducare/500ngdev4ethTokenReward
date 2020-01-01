<<<<<<< HEAD
 

pragma solidity >=0.5.0 < 0.6.0;
contract TokenReward {
    
     address public owner; 
    
    struct Member {
        uint8 rating;
        string name;
        bool isWhitelisted;
        uint8 accumulatedPoints;
    }
    //Mappings
    

    // This generates a public event on the blockchain that will notify clients
  

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
     
        
    mapping(address => Member) public members;//each Member has an address
    mapping(address => uint ) public reward;//captures the reward in uint of each address
    mapping(address => bool ) public admins;//captures the addresses that are admins or not
    mapping(address => uint ) public balances;//captures the balances in uint of each address
    mapping (address => mapping (address => uint256)) public allowance;
    //Events
    event NewMember(string _name);//Trigers when a new name is added
    event Blacklisted(address indexed _member, string _name);//trigers new blacklisting
    event NewReward(address indexed _member, uint reward);//trigers new reward and the member
    event NewRating(address indexed _ratedBy, address indexed _memberRated, uint rating);//trigers new rating
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
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
     modifier onlyOwner {
    require(msg.sender == owner,"only the owner can call this");
   //onlyOwner checks whether the msg.sender is the same as the owner
    _;
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
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = true;
       return true;
    }
    
   //This function blcacklist a member and can be called only by admins and the owner
    function blackListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = false;
       return true;
    }
    
   // This function checks if a member is whitelisted or not
    function isWhitelisted(address __member)internal view returns(bool) {
        Member memory  memberStruct = members[__member];
        return memberStruct.isWhitelisted;
    }
    //This function rate a member and can be called by admins,owners,and whitelisted members
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
        return (__pointremained, __starRating
        );
    }

    function transferOwnership(address newOwner) public  onlyOwner{
        owner = newOwner;}
}
interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
    
}

contract NgDevsforEth is TokenReward {
     uint256 public _totalsupply;
     string public _name;
    string public _symbol;
    uint8 public _decimals = 18;
   
  constructor(uint256 totalsupply,string memory name,string memory symbol, uint8  decimals)public{
      _totalsupply = totalsupply;
         _name = name;
        _symbol = symbol;
        _decimals = decimals;
     }
    
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
       // require(_to != address(0x0));
        // Check if the sender has enough
        require(balances[_from] >= _value,"Balances from must be greater than transfer");
        // Check for overflows
        require(balances[_to] + _value >= balances[_to],"Balances to must be less than transfer");
        // Save this for an assertion in the future
        uint previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to for static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);
    }
    
    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfers(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender],"value transfer must be less than allowance");// Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value,"balance of owner must be greater than amount burnt");// Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value,"value burnt must be less than available balance"); // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender],"value burnt must be less than or equal to allowance"); // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        balances[msg.sender] -= _value;                              
        emit Burn(_from, _value);
        return true;
    }
}
=======
pragma solidity >=0.5.0 < 0.6.0;
contract TokenReward {
    
    struct Member {
        uint8 rating;
        string name;
        bool isWhitelisted;
        uint8 accumulatedPoints;
    }
    //Mappings
    address owner;//Our state variable
    mapping(address => Member) public members;//each Member has an address
    mapping(address => uint ) public reward;//captures the reward in uint of each address
    mapping(address => bool ) public admins;//captures the addresses that are admins or not
    mapping(address => uint ) public balances;//captures the balances in uint of each address
    //Events
    event NewMember(string _name);//Trigers when a new name is added
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
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = true;
       return true;
    }
    

   //This function blcacklist a member and can be called only by admins and the owner
    function blackListMember(address __member) public view OnlyAdminOrOwner returns(bool) {
       Member memory  memberStruct = members[__member];
       memberStruct.isWhitelisted = false;
       return true;
    }
    
   // This function checks if a member is whitelisted or not
    function isWhitelisted(address __member)internal view returns(bool) {
        Member memory  memberStruct = members[__member];
        return memberStruct.isWhitelisted;
    }
    //This function rate a member and can be called by admins,owners,and whitelisted members
    function rateMember(address __membertorate) public OnlyAdminOrOwner IsWhitelisted(__membertorate) returns(bool) {
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
        return (__pointremained, __starRating
        );
    }
}









>>>>>>> 6d60512c227cf4badb15a7835f66e5a62a723ce8
