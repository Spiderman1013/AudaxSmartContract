pragma solidity ^0.8.6;
// SPDX-License-Identifier: GPL-3.0


contract AudaxSystem {

address constant register = 0x17926cFC5AE81a0F2ec497D16f924c3f36170C40;
address constant owner1 = 0x629fA22033110778B985AC9C18C0C780D0515Ba4;
address constant owner2 = 0xE016DB553a6b2655b32B8D65489d836fe64E789B;
  

    RegisterOfDeeds public rd ;

    constructor() {    
        require(tx.origin==register, "Only register can start the system");
        rd = new RegisterOfDeeds(tx.origin);
    } 

    function addProperties() public {
        rd.NewProperty("44850 Lafayette Dr",owner1);
        rd.NewProperty("44855 Lafayette Dr",owner2);
    }

    function startSale() public {        
        string memory propAddr = "44850 Lafayette Dr";
        SaleDeed saleDeed = new SaleDeed(owner2,rd.LookupProperty(propAddr));
        saleDeed.sell();
    }

}


contract RegisterOfDeeds {

    address register;

    mapping(string=>address) public propLookup;

    constructor(address _register)  {
     register = _register;
    }


    function NewProperty(string memory _proAddress,address _propOwner) public {
        require(propLookup[_proAddress]==address(0), string(abi.encodePacked(" Property already exists: ",_proAddress ))  );
        NFPT n = new NFPT(_proAddress,_propOwner);
        propLookup[_proAddress]=address(n);        
    }

    function ChangeOnwer(string memory _proAddress,address _newOnwer) public {
        require(propLookup[_proAddress]!=address(0), string(abi.encodePacked(" Property does not exists: ",_proAddress ))  );
        
        NFPT n = NFPT( propLookup[_proAddress]);

        n.changeOnwer( _newOnwer);      
    }

    function LookupProperty(string memory propAddress) public view returns(NFPT)
    {
        NFPT prop = NFPT(propLookup[propAddress] );        
        return prop;
    }

}


// NFPTs represent NON Fungible Properity Titles
contract NFPT {

    string public proAddress;
    address  public propOwner;
    address  public registerOfDeeds;

    event PropertySold (string proAddress,address seller,address buyer);

    constructor(string memory _proAddress,address _propOwner)  {
        require(tx.origin != msg.sender, "Only RegisterOfDeeds can create the NFPT ");
        proAddress = _proAddress;
        propOwner = _propOwner;
        registerOfDeeds = msg.sender;
    }

    function changeOnwer(address _newPropOwner) public {
       // require(registerOfDeeds!= msg.sender, "Only the RegisterOfDeeds can update the NFPT ");
       emit PropertySold(proAddress,propOwner,_newPropOwner);

        propOwner = _newPropOwner;
    }    
}


contract SaleDeed {

    enum SaleStatus {
        NULL,
        NEW_SALE,
        VERIFIED,
        PAID,
        PAYMENT_RECEVIED,
        SOLD
    }

    address public seller;
    address public buyer;
    NFPT public prop;
    SaleStatus status;
    
   

    constructor(address _buyer,NFPT _prop ) 
    {
        seller = msg.sender;
        buyer = _buyer;
        prop = _prop;
    }

    function sell() public 
    {
        //require(seller==prop.propOwner,"Only current owner can sell");
        status = SaleStatus.NEW_SALE;

    }

    function verifySale() public
    {
        //require(msg.sender == prop.registerOfDeeds, "Only register can veriy the sale" );
        status = SaleStatus.VERIFIED;      
    }
}
