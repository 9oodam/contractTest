// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

// createPair 할 때마다 ERC20(LP)의 CA가 매번 새롭게 생성되게
contract LPToken is ERC20 {
    address public lpAddress;
    constructor(address _address) {
        lpAddress = _address;
    }
}
contract Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    address token0Address;

    function createPair(address tokenA, address tokenB) public returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES'); // 동일한 토큰이면 안됨
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); // 주소가 작은 게 앞으로
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS'); // token0 의 주소가 0이면 안됨
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS');

        // 2개의 토큰 주소로 새로운 pair 주소 생성
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1); // 초기화

        // 혹시 모르니 크로스로 저장
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);

        // 새로 생긴 pair 주소로 LP token CA 생성
        LPToken created = new LPToken(pair);
    }
}


// Swap
contract Pair {
    address tokenAddress = '0x124354547395082';

    mapping (address owner => uint lpTokenAmount) balances;


    // 유동성 추가
    function addLiquidity() public payable {}
    // 유동성 제거
    function removeLiquidity(uint lpTokenAmount) public {
        // 지분율 계산 (전체 lp / 보유자의 lp)
        // lpTokenAmount / balanceOf(address(this)); // or balances[address(this)]

        // Ether 지분율
        uint etherAmount = address(this).balance * lpTokenAmount / balanceOf(address(this));
        // Token 지분율
        ERC20 token = ERC20(tokenAddress);
        uint tokenAmount = token.balanceOf(address(this)) * lpTokenAmount / balanceOf(address(this));

        // 계산된 ether, token 보내기
        payable(msg.sender).transfer(etherAmount);
        token.transfer(msg.sender, tokenAmount);

        // lp 소각
        _burn(msg.sender, lpTokenAmount);
    }



    // 사용자가 지불하고 싶은 Ether의 input을 정했을 때
    function etherToTokenInput(uint minTokens) public payable {
        ERC20 token = ERC20(tokenAddress);

        uint etherAmount = msg.value; // 사용자가 보낸 이더
        uint tokenAmount = getInputPrice(
            etherAmount,
            address(this).balance - msg.value, // 현재 보유량에서 방금 받은 이더 빼고 계산
            token.balanceOf(address(this))
        ); 
        require(tokenAmount >= minTokens); // 슬리피지 발생으로 사용자가 생각한 것보다 현저하게 적은 토큰을 받을 수 있기 때문에 최소수량 설정
        
        token.transfer(msg.sender, tokenAmount);
    }
    function tokenToEthInput() {

    }
    // getInputPrice == getOutputAmount 가격을 넣고 토큰 양을 얻는 것
    function getInputPrice(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns (uint outputAmount) {
        // CSMM
        // return inputAmount * 997 / 1000; // 수수료 3% 제외

        // CPMM : x * y / (x + 추가된 금액)
        uint numerator = inputAmount * outputReserve;
        uint denominator = inputAmount + inputReserve;
        uint outputAmountWithFee = numerator / denominator;
        outAmount = outputAmountWithFee * 997 / 1000; // 0.3% 제외
    }

    // 사용자가 받고싶은 Token의 output을 정했을 때
    function etherToTokenOutput(uint tokenAmount) public payable {
        uint etherAmount = getOutputPrice(tokenAmount, 0, 0); // token 특정 개수를 얻고 싶으면 반대로 이더를 계산
        require(msg.value >= etherAmount); // 슬리피지 발생 가능성이 있기 때문에 사용자가 보낸 이더가 무조건적으로 필요한 이더의 양보다 많아야 함

        // 쓰고 남은건 돌려줌
        uint etherRefundAmount = msg.value - etherAmount; 
        if (etherRefundAmount > 0) {
            payable(msg.sender).transfer(etherRefundAmount);
        }

        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender, tokenAmount);
    }
    function tokenToEthOutput() {

    }
    // getOutputPrice == getInputAmount 받을 양을 정하고 넣을 가격을 정하는 것
    function getOutputPrice(uint outputAmount, uint inputReserve, uint outputReserve) public pure returns (uint inputAmount) {
        // CSMM
        // return outputAmount / 997 * 1000;

        // CPMM
        // (X, Y) -> (X + A, Y - B) 에서 B가 고정되어 있을 때 A를 구하는 법
        uint numerator = inputReserve * outputAmount;
        uint denominator = outputReserve - outputAmount;
        uint inputAmountWithoutFee = numerator / denominator;
        inputAmount = inputAmountWithFee * 1000 / 997; // 3% 포함
    }
}