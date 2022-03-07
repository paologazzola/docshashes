// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";

contract DataCerta is Owner {

    mapping(bytes32 => bool) private documents;

    modifier isRawDocHashPresent(bytes32 _rawHash) {
        require(
            documents[_rawHash] == true,
            "Document raw hash is not present"
        );
        _;
    }

    modifier isRawDocHashNotPresent(bytes32 _rawHash) {
        require(
            documents[_rawHash] == false,
            "Document raw hash is already present"
        );
        _;
    }

    constructor() {}

    function insertRawHash(bytes32 _rawHash)
        external
        isOwner
        isRawDocHashNotPresent(_rawHash)
    {
        documents[_rawHash] = true;
    }

    function isDocumentPresent(bytes32 _rawHash)
        external
        view
        returns (
            bool isPresent
        )
    {
        return documents[_rawHash];
    }

    function getBalance() external view isOwner returns (uint256) {
        return address(this).balance;
    }

    function selfDestruct() external isOwner {
        selfdestruct(payable(msg.sender));
    }
}

