// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    // string public name; // 토큰 이름
    // string public symbol; // 토큰 단위
    string public uri; // 토큰 이미지

    // uint8 public decimals = 18; // 소숫점 자리
    // uint public override totalSupply; // 토큰 총량
    uint public totalVolume; // 토큰 총거래량

    address private owner; // 컨트랙트 배포자
    mapping(address => uint) public balances; // 누가 얼만큼 가지고 있는지 정보가 들어있는 객체
    // mapping(address => mapping(address => uint)) public override _allowances; // 소유권 위임 받은 정보

    constructor(string memory _name, string memory _symbol, uint256 _amount, string memory _uri) ERC20(_name, _symbol) {
        owner = msg.sender;
        // name = _name;
        // symbol = _symbol;
        uri = tokenURI(_uri);

        _mint(_amount * (10 ** decimals()));
    }

    // 토큰 발행
    function _mint(uint amount) internal {
        balances[msg.sender] += amount;
        _totalSupply += amount;
    }

    // 매개변수로 전달한 계정의 토큰 잔액 확인
    function balanceOf(address account) public view override returns (uint) {
        return balances[account];
    }

    // 토큰 전송
    function transfer(address to, uint amount) public override returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }

    // 토큰 위임
    function approve(address spender, uint amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    // 위임 받은 토큰을 전송
    function transferFrom(address sender, address to, uint amount) public override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount);
        _allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[to] += amount;
        return true;
    }

    // 토큰 태우기
    function burn(uint amount) external {
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
    }


    function tokenURI(string memory _imageUri) public view returns (string memory) {
        return string.concat(_baseURI(), _imageUri);
    }
    function _baseURI() internal view returns (string memory) {
        return "https://crimson-generous-ant-395.mypinata.cloud/ipfs/";
    }

    // totalVolume 값 수정
    
}