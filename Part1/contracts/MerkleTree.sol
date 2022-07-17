//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    using PoseidonT3 for uint256[2] ;

    constructor() {
        hashes=[0,0,0,0,0,0,0,0];
        uint256 n=hashes.length;
        uint256 offset=0;
        while (n>0) {
            for (uint256 i=0; i<n-1;i+=2) {
                uint256[2] memory arvg=[hashes[offset +i],hashes[offset +i+1]];
                uint256 ahash=PoseidonT3.poseidon(arvg);
                hashes.push(ahash);
            }
            offset +=n;
            n=n/2;

        }
        root =hashes[14];
        // [assignment] initialize a Merkle tree of 8 with blank leaves
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        for (uint256 i=0;i<8;i++) {
            if (hashes[i]==0) {
                hashes[i]=hashedLeaf;
                if (i==0 || i==1){
                    hashes[8]=PoseidonT3.poseidon([hashes[0],hashes[1]]);
                    hashes[12]=PoseidonT3.poseidon([hashes[8],hashes[9]]);
                    hashes[14]=PoseidonT3.poseidon([hashes[12],hashes[13]]);
                }
                else if (i==2 || i==3){
                    hashes[9]=PoseidonT3.poseidon([hashes[2],hashes[3]]);
                    hashes[12]=PoseidonT3.poseidon([hashes[8],hashes[9]]);
                    hashes[14]=PoseidonT3.poseidon([hashes[12],hashes[13]]);
                }

                else if (i==4 || i==5){
                    hashes[10]=PoseidonT3.poseidon([hashes[4],hashes[5]]);
                    hashes[13]=PoseidonT3.poseidon([hashes[10],hashes[12]]);
                    hashes[14]=PoseidonT3.poseidon([hashes[12],hashes[13]]);
                }
                else if (i==6 || i==7){
                    hashes[11]=PoseidonT3.poseidon([hashes[6],hashes[7]]);
                    hashes[13]=PoseidonT3.poseidon([hashes[10],hashes[11]]);
                    hashes[14]=PoseidonT3.poseidon([hashes[12],hashes[13]]);
                }
                break;
            }
        }
        root =hashes[14];
        return hashedLeaf;
        // [assignment] insert a hashed leaf into the Merkle tree
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
            if ((verifyProof(a, b, c, input)) && input[0] == root){
                return true;
            } 
            else {
                return false;
            }

        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
