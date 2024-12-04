MODELS_DIR=models
TRAIN_CONLL=/net/data/CoNLL/2006/cs/train.conll
DEV_CONLL=/net/data/CoNLL/2006/cs/test.conll  # TODO SPLIT TO DEV TOO
TEST_CONLL=/net/data/CoNLL/2006/cs/test.conll
TEST_PARSED_CONLL=$(MODELS_DIR)/test_parsed.conll

TRAIN_ORACLE=$(MODELS_DIR)/trainingOracle.txt 
DEV_ORACLE=$(MODELS_DIR)/devOracle.txt 


all: $(TEST_PARSED_CONLL)

$(MODELS_DIR):
	mkdir -p $@

$(TRAIN_ORACLE): $(TRAIN_CONLL)
	java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c  $(TRAIN_CONLL) > $@
	echo; echo "$@ oracle estimated"; echo


$(DEV_ORACLE): $(DEV_CONLL)
	java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c  $(DEV_CONLL) > $@
	echo; echo "$@ oracle estimated"; echo

$(TEST_ORACLE): $(TEST_CONLL)
	java -jar ParserOracleArcStdWithSwap.jar -t -1 -l 1 -c  $(TEST_CONLL) > $@
	echo; echo "$@ oracle estimated"; echo



# echo 'for english' ; build/parser/lstm-parse -T $models_dir/trainingOracle.txt -d $models_dir/devOracle.txt --hidden_dim 100 --lstm_input_dim 100 -w $models_dir/sskip.100.vectors --pretrained_dim 100 --rel_dim 20 --action_dim 20 -t -P

# the pretrained embeddings are for english only

latest_model: $(TRAIN_ORACLE) $(DEV_ORACLE)
	@echo "removing -P option so no POS"
	build/parser/lstm-parse -T $(TRAIN_ORACLE) -d $(DEV_ORACLE) --hidden_dim 100 --lstm_input_dim 100 --pretrained_dim 100 --rel_dim 20 --action_dim 20 -t
	echo; echo 'some model trained with the lstm parsing'; echo

$(TEST_PARSED_CONLL): $(TRAIN_ORACLE) $(DEV_ORACLE)
	@echo "removing -P option so no POS"
	build/parser/lstm-parse -T $(TRAIN_ORACLE) -d $(DEV_ORACLE) --hidden_dim 100 --lstm_input_dim 100 --pretrained_dim 100 --rel_dim 20 --action_dim 20 -m latest_model > $@
	echo; echo 'Decoded $@'; echo

clean: 
	rm -f $(TRAIN_ORACLE) $(DEV_ORACLE) $(TEST_PARSED_CONLL)
