// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBounswapFactory.sol";
import "./IBounswapPair.sol";
import "./BounswapPair.sol";
import "./BounswapERC20.sol";
import "./WBNC.sol";

contract BounswapFacotry is IBounswapFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address[] public allTokens;

    mapping (address pa => Pair) pairAddress;
    mapping (address validator → address pairAddress[]) validatorPoolArr;

    Struct TokenData {
        tokenAddress,
        name, // 이름
        symbol, // 심볼
        uri, // 이미지
        // price, // 가격
        // change, // 가격변동
        tvl, // 총 예치량
        volume // 총 거래량
    }

    Struct Data {
        address token0Address; // token0 CA
        uint token0; // token0 총예치량

        address token1Address;
        uint token1;

        uint loToken; // 발행된 Lp token
    }

    Struct allPoolData {
        address, // 누가 이 풀의 지분을 가지고 있는지
        Data
    }


    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;

        // 토큰 4개 발행 (WBND, ETH, USDT, BNB)
        WBNC bnc = new WBNC('Wrapped Bounce Coin', 'WBNC', 10000, "");
		Token eth = new Token('ethereum', 'ETH', 10000, "");
		Token usdt = new Token('Tether', 'USDT', 10000, "");
		Token bnb = new Token ('Binance Coin', 'BNB', 10000, "");

        allTokens.push(address(bnc));
		allTokens.push(address(eth));
		allTokens.push(address(usdt));
		allTokens.push(address(bnb));
    }


    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getAllTokenAddress() public view returns (address[]) {
        return allTokens;
    }

    // 2개의 token에 해당하는 pair address 를 반환
    function getPairAddress(address tokenA, address tokenB) public view returns (address) {
        return getPair[tokenA][tokenB];
    }


    // pair 처음 생성할 때 실행
    function createPairAddress(address tokenA, address tokenB) internal returns (address pair) {
        bytes memory bytecode = type(BounswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // 초기화
        IBounswapPair(pair).initialize(token0, token1);

        // getPair, allPairs 에 새로 생긴 pairAddress 저장
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);

        // 새로 생긴 pair 주소로 LP token CA 생성
        pairAddress[pair] = new Pair(pair);

        return pair;
    }

    // 사용자가 New position 누르면 실행
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'same token');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'zero address');

        // 처음 생성하는 경우
        if(getPair[token0][token1] == address(0)) {
            pair = createPairAddress(address tokenA, address tokenB)
        }else {
            pair = getPair[token0][token1];
        }  

        // 특정 유저의 Pool arr에 추가
        // 이미 있으면 중복 안되게, 삭제되면 pop
        bool isDuplicated = false;
        for(uint i=0; i<validatorPoolArr[msg.sender].length; i++) {
            if(validatorPoolArr[msg.sender][i] == pair) {
                isDuplicated == true;
                break;
            }
        }
        require(isDupulicated == false);
        validatorPoolArr[msg.sender].push(pair);

        pairAddress[pair].mint(msg.sender);
    }



    // 플랫폼 내 모든 토큰을 반환하는 함수
    function getAllTokens() returns (TokenData[] memory) {
        for(uint i=0; i<allTokens.length; i++) {
            Token token = Token(allTokens[i]);
            arr[i] = TokenData(allTokens[i], token.name, token.symbol, token.uri,
            token.totalSupply, token.totalVolume);
        }
        return arr;
    }

    // 빈 배열 생성(arr)
    // 전체 dash board 반환
    // function getAllPools() returns (address[], Data[]) {
    function getAllPools() returns (allPoolData[]) {
        for (uint i=0; i<allPairs.length; i++) {
            arr[i] = allPoolData(allPairs[i], pairAddress[allPairs[i]].getAllData());
            // arr[i] = pairAddress[allPairs[i]].getAllData();
        }
        // return (allPairs, arr);
        return arr;
    }

    function getUserPools() returns (Data[]) {
        address[] userPool = validatorPoolArr(msg.sender);
        for (uint i=0; i<userPool.length; i++) {
            arr[i] = pairAddress[validatorPoolArr[i]].getData(msg.sender);
            // arr[i] = poolData[userPool[i]];
        }
        return arr;
    }






    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}