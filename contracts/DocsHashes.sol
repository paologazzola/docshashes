// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";

contract DocsHashes is Owner {
    enum HashingAlgorithmsEnum {
        SHA256,
        SHA512
    }

    HashingAlgorithmsEnum constant defaultHashingAlgorithm =
        HashingAlgorithmsEnum.SHA256;

    struct Signature {
        string signedHash;
        HashingAlgorithmsEnum signatureHashingAlgorithm;
    }

    struct Document {
        bool isPresent;
        uint8 numOfSignatures;
        Signature[] signatures;
    }

    mapping(bytes32 => Document) private documents;

    modifier isRawDocHashPresent(bytes32 _rawHash) {
        require(
            documents[_rawHash].isPresent == true,
            "Document raw hash is not present"
        );
        _;
    }

    modifier isRawDocHashNotPresent(bytes32 _rawHash) {
        require(
            documents[_rawHash].isPresent == false,
            "Document raw hash is already present"
        );
        _;
    }

    modifier isSignaturePresent(bytes32 _rawHash, uint8 _signatureArrayIndex) {
        require(
            documents[_rawHash].numOfSignatures > _signatureArrayIndex,
            "Signature Array Index out of bounds"
        );
        _;
    }

    constructor() {}

    function insertRawHash(bytes32 _rawHash)
        external
        isOwner
        isRawDocHashNotPresent(_rawHash)
    {
        Document storage newDoc = documents[_rawHash];
        newDoc.isPresent = true;
        documents[_rawHash] = newDoc;
    }

    function addSignature(
        bytes32 _rawHash,
        string memory _signedHash,
        HashingAlgorithmsEnum _signatureHashingAlgorithm
    ) external isOwner isRawDocHashPresent(_rawHash) {
        documents[_rawHash].numOfSignatures++;
        documents[_rawHash].signatures.push(
            Signature({
                signedHash: _signedHash,
                signatureHashingAlgorithm: _signatureHashingAlgorithm
            })
        );
    }

    function insertRawHashAndSignature(
        bytes32 _rawHash,
        string memory _signedHash,
        HashingAlgorithmsEnum _signatureHashingAlgorithm
    ) external isOwner isRawDocHashNotPresent(_rawHash) {
        Document storage newDoc = documents[_rawHash];
        newDoc.isPresent = true;
        newDoc.numOfSignatures++;

        newDoc.signatures.push(
            Signature({
                signedHash: _signedHash,
                signatureHashingAlgorithm: _signatureHashingAlgorithm
            })
        );

        documents[_rawHash] = newDoc;
    }

    function getDocument(bytes32 _rawHash)
        external
        view
        isRawDocHashPresent(_rawHash)
        returns (
            bytes32 rawHash,
            HashingAlgorithmsEnum hashingAlgorithm,
            uint8 numOfSignatures
        )
    {
        uint8 numOfSignaturesCounter;
        for (uint8 i = 0; i < documents[_rawHash].signatures.length; i++) {
            numOfSignaturesCounter++;
        }

        return (_rawHash, defaultHashingAlgorithm, numOfSignaturesCounter);
    }

    function getSignatures(bytes32 _rawHash, uint8 _signatureArrayIndex)
        external
        view
        isRawDocHashPresent(_rawHash)
        isSignaturePresent(_rawHash, _signatureArrayIndex)
        returns (
            bytes32 rawHash,
            string memory _signedHash,
            HashingAlgorithmsEnum signatureHashingAlgorithm
        )
    {
        return (
            _rawHash,
            documents[_rawHash].signatures[_signatureArrayIndex].signedHash,
            documents[_rawHash]
                .signatures[_signatureArrayIndex]
                .signatureHashingAlgorithm
        );
    }

    function getBalance() external view isOwner returns (uint256) {
        return address(this).balance;
    }

    function selfDestruct() external isOwner {
        selfdestruct(payable(msg.sender));
    }
}

