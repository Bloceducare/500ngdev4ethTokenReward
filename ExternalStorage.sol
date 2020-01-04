pragma solidity >=0.4.22 <0.6.0;

contract ExternalStorage{
    

    mapping(bytes32 => uint) internal uIntStorage;
    mapping(bytes32 => address) internal addressStorage;

    struct Profile{
        string name;
        uint phone;
        address ethaddress;
    }
    
    bytes32[] account;
}
