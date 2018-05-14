pragma solidity ^0.4.23;

// simple contract that let's the manager set as many issuers as he wants for an issued token
// the issued token must set the issuer controller as it's issuer

import "./Managed.sol";
import "./IssuedToken.sol";

contract IssuerController is Managed {

    IssuedToken public issuedToken;
    mapping (address => bool) public isIssuer;
    mapping (address => uint256) private issuersIndex;
    address[] public issuers;

    constructor(IssuedToken _issuedToken) public {
        issuedToken = _issuedToken;
    }

    modifier issuerOnly() {
        require(isIssuer[msg.sender]);
        _;
    }

    function addIssuer(address _issuer) public managerOnly {
        require(!isIssuer[_issuer]);
        isIssuer[_issuer] = true;
        issuersIndex[_issuer] = issuers.length;
        issuers.push(_issuer);
    }

    function deleteIssuer(address _issuer) public managerOnly {
        require(isIssuer[_issuer]);
        delete isIssuer[_issuer];
        issuers[issuersIndex[_issuer]] = issuers[issuers.length - 1];
        delete issuers[issuers.length - 1];
        issuers.length--;
    }

    function issue(address _to, uint256 _value) public issuerOnly {
        issuedToken.issue(_to, _value);
    }

    function destroy(address _from, uint256 _value) public issuerOnly {
        issuedToken.destroy(_from, _value);
    }

}
