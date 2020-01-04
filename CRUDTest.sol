pragma solidity >=0.4.22 <0.6.0;
import "./ExternalStorage.sol";

contract CallingContract is ExternalStorage{
    
     address owner = msg.sender;
     address latestOwner;
    
    modifier onlyOwner() {
       require(msg.sender == latestOwner);
        _;
    }

    function changeOwner(address _newOwner) public {
        require(msg.sender == owner);
        latestOwner = _newOwner;
    }
    
    // *** Getter Methods ***
    function getUint(bytes32 _key) internal view returns(uint) {
        return uIntStorage[_key];
    }

    function getAddress(bytes32 _key) external view returns(address) {
        return addressStorage[_key];
    }

    // *** Setter Methods ***
    function setUint(bytes32 _key, uint _value) onlyOwner internal {
        uIntStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) onlyOwner internal {
        addressStorage[_key] = _value;
    }

    // *** Delete Methods ***
    function deleteUint(bytes32 _key) onlyOwner external {
        delete uIntStorage[_key];
    }

    function deleteAddress(bytes32 _key) onlyOwner external {
        delete addressStorage[_key];
    }
    
    
    function getBalance(address balanceHolder) public view returns(uint) {
        return getUint( keccak256(abi.encodePacked("balances", balanceHolder)) );
    }
    
    function setBalance(address balanceHolder, uint amount) public {
        setUint(keccak256(abi.encodePacked("balances", balanceHolder)), amount);
    }
    
    function addBalance(address balanceHolder, uint amount) public {
        setBalance(balanceHolder, getBalance(balanceHolder) + amount);
    }
}
