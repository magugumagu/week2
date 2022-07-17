pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    component hash =Poseidon(2**n);
    for (var i=0; i<(2**n ); i++) {
        hash.inputs[i] <== leaves[i];
    }
    root <== hash.out;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal
    var leaf_=leaf;

    component hash[n];
    component select[n][2];
    for (var i=0; i<n; i++　){
        hash[i]=Poseidon(2);
        select[i][0]=Mux1();
        select[i][0].c[0] <==leaf_;
        select[i][0].c[1] <==path_elements[i];
        select[i][0].s <==path_index[i];
        hash[i].inputs[0] <==select[i][0].out;
        select[i][1]=Mux1();
        select[i][1].c[0] <== leaf_;
        select[i][1].c[1] <==path_elements[i];
        select[i][1].s <==1-1*path_index[i];
        hash[i].inputs[1] <==select[i][1].out;
        leaf_= hash[i].out;
    }
    root <==leaf_;

}


template MultiMux1(n) {
    signal input c[n][2];  // Constants
    signal input s;   // Selector
    signal output out[n];

    for (var i=0; i<n; i++) {

        out[i] <== (c[i][1] - c[i][0])*s + c[i][0];

    }
}

template Mux1() {
    var i;
    signal input c[2];  // Constants
    signal input s;   // Selector
    signal output out;

    component mux = MultiMux1(1);

    for (i=0; i<2; i++) {
        mux.c[0][i] <== c[i];
    }

    s ==> mux.s;

    mux.out[0] ==> out;
}