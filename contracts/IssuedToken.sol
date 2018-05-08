pragma solidity ^0.4.23;

// TODO: figure out why inheriting the interface doesn't allow compiling
// import "./ERC20Interface.sol";
import "./AntiERC20Sink.sol";
import "./SafeMath.sol";

contract IssuedToken is AntiERC20Sink {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    address public issuer;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Issue(address indexed _to, uint256 _value);
    event Destroy(address indexed _from, uint256 _value);

    constructor(string _name, string _symbol, uint8 _decimals, address _issuer) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        issuer = _issuer;
    }

    modifier issuerOnly() {
        require(msg.sender == issuer);
        _;
    }

    modifier notZeroAddress(address _to) {
        require(_to != 0x0);
        _;
    }

    function transfer(address _to, uint256 _value) public notZeroAddress(_to) returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].minus(_value);
        balanceOf[_to] = balanceOf[_to].plus(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public notZeroAddress(_to) returns (bool) {
        balanceOf[_from] = balanceOf[_from].minus(_value);
        balanceOf[_to] = balanceOf[_to].plus(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function issue(address _to, uint256 _value) public issuerOnly {
        balanceOf[_to] = balanceOf[_to].plus(_value);
        totalSupply = totalSupply.plus(_value);
        emit Issue(_to, _value);
        emit Transfer(0x0, _to, _value);
    }

    function destroy(address _from, uint256 _value) public issuerOnly {
        balanceOf[_from] = balanceOf[_from].minus(_value);
        totalSupply = totalSupply.minus(_value);
        emit Destroy(_from, _value);
        emit Transfer(_from, 0x0, _value);
    }

    function setIssuer(address _issuer) public managerOnly {
        issuer = _issuer;
    }

}
