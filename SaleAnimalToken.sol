// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken {
    MintAnimalToken public mintAnimalTokenAddress;
    
    constructor(address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    mapping(uint256 => uint256) public animalTokenPrices;

    uint256[] public onSaleAnimalTokenArray;

    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public {
        // 입력된 animalTokenId의 주인을 받아온다
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(animalTokenOwner == msg.sender, "Caller is not animal token owner");
        require(_price > 0, "Price is zero or lower");
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale");

        // owner가 이 컨트랙트(SaleAnimalToken)에 권한을 넘겼는지 여부 확인
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");

        animalTokenPrices[_animalTokenId] = _price;

        onSaleAnimalTokenArray.push(_animalTokenId);
    }

    function purchase(uint256 _animalTokenId) public payable {
        uint256 price = animalTokenPrices[_animalTokenId];
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);
        // price == 0 : 판매등록이 되어있지 않다.
        require(price > 0, "Animal token not sale.");
        require(price <= msg.value, "Caller sent lower than price");
        require(animalTokenOwner != msg.sender, "Caller is animal token owner");

        payable(animalTokenOwner).transfer(msg.value);
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);

        // 
        animalTokenPrices[_animalTokenId] = 0;

        for (uint256 i = 0; i < onSaleAnimalTokenArray.length; i++) {
            if (animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    function getOnSaleAnimalTokenArrayLength() public view returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }
}