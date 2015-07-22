#!/bin/bash
echo 'starting'; echo
mkdir -p models

# java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c /net/data/CoNLL/2006/cs/train.conll  > models/trainingOracle.txt 
echo; echo "train oracle estimated"; echo

java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c /net/data/CoNLL/2006/cs/test.conll> models/devOracle.txt
echo; echo "dev oracle estimated - TODO test data used"; echo

build/parser/lstm-parse -T models/trainingOracle.txt -d models/devOracle.txt --hidden_dim 100 --lstm_input_dim 100 -w models/sskip.100.vectors --pretrained_dim 100 --rel_dim 20 --action_dim 20 -t -P
echo; echo 'something trained with the lstm parsing - TODO test oracle used instead of dev'; echo


java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c /net/data/CoNLL/2006/cs/test.conll > models/testOracle.txt
echo; echo 'test oracle estimated'; echo
parser/lstm-parse -T models/trainingOracle.txt -d models/testOracle.txt --hidden_dim 100 --lstm_input_dim 100 -w sskip.100.vectors --pretrained_dim 100 --rel_dim 20 --action_dim 20 -P -m parser_pos_2_32_100_20_100_12_20-pidXXXX.params
echo; echo 'decoding'; echo
