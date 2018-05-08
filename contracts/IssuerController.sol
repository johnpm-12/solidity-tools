pragma solidity ^0.4.23;

// simple contract that let's the manager set as many issuers as he wants for an issued token

import "./AntiERC20Sink.sol";
import "./IssuedToken.sol";

contract IssuerController is AntiERC20Sink {

    IssuedToken public issuedToken;
    struct SetAndIndex {
        bool isSet;
        uint256 index;
    }
    mapping (address => SetAndIndex) public issuerInfo;
    address[] public issuers;
    uint256 public issuerCount;

    constructor(IssuedToken _issuedToken) public {
        issuedToken = _issuedToken;
    }

    modifier issuerOnly() {
        require(issuerInfo[msg.sender].isSet);
        _;
    }

    function addIssuer(address _issuer) public managerOnly {
        require(!issuerInfo[_issuer].isSet);
        issuerInfo[_issuer] = SetAndIndex({ isSet: true, index: issuers.length });
        issuers.push(_issuer);
        issuerCount++;
    }

    function deleteIssuer(address _issuer) public managerOnly {
        require(issuerInfo[_issuer].isSet);
        delete issuers[issuerInfo[_issuer].index];
        delete issuerInfo[_issuer];
        issuerCount--;
    }

    function issue(address _to, uint256 _value) public issuerOnly {
        issuedToken.issue(_to, _value);
    }

    function destroy(address _from, uint256 _value) public issuerOnly {
        issuedToken.destroy(_from, _value);
    }

}
