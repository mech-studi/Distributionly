pragma solidity 0.5.1; 

contract DomainKeeper{
    uint256 counter = 0 ; 
    mapping(uint256 => iDomain) domains; 
    struct iDomain{
        uint _id;
        string owner;
        address ipaddress;
        //string domainname; 
    }
    
    
    
    // function to add new ipaddress:    
    function addIp(string memory _owner, address  _ipaddress) public{
        
        if ( !alreadyregister(_ipaddress)){
            counter += 1;
            domains[counter] = iDomain(counter,_owner, _ipaddress);    
        }
        // what happen if the ip is alreadyregister??
        //create and event to inform when is gonna be free again? 
    } 
    
    function getOwner(uint256 id) public view returns(string memory){
        return domains[id].owner;
       
    }
    
    function getAdress(uint256 id) public view returns(address){
        return domains[id].ipaddress;
       
    }
    // function to checked if the ip is already in our register
    function alreadyregister(address _ipaddress)public view returns(bool){
         
        for (uint i = 0; i < counter; i++){
            if(domains[counter].ipaddress == _ipaddress){
                return true;
            } 
        }
        return false;
    }
    
    
    }
    