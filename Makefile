
GID?=3

COCO_ROOT=../clcv/resources/corpora/Microsoft_COCO

MODEL_DIR=model
OUT_DIR=out

MODEL_FILE=$(MODEL_DIR)/model_id1-501-1448236541.t7
$(MODEL_FILE):
	mkdir -p $(MODEL_DIR)
	wget -P $(MODEL_DIR) http://cs.stanford.edu/people/karpathy/neuraltalk2/checkpoint_v1.zip
	cd $(MODEL_DIR); unzip checkpoint_v1.zip; rm checkpoint_v1.zip; cd -

eval: $(OUT_DIR)/val2014_neuraltalk2.json
$(OUT_DIR)/val2014_neuraltalk2.json: $(MODEL_FILE) \
	$(COCO_ROOT)/annotations/captions_val2014.json 
	mkdir -p $(OUT_DIR)
	CUDA_VISIBLE_DEVICES=$(GID) th eval.lua -model $< \
		-coco_json $(word 2,$^) \
		-output_json $@ \
		-image_folder $(COCO_ROOT)/images/val2014 \
		-num_images -1 -language_eval 0 -dump_images 0 -dump_json 1

BEAM_SIZES=1 2 3 4 5 6 7 8 9 10
eval_beam: $(patsubst %,$(OUT_DIR)/val2014_neuraltalk2_beam%.json,$(BEAM_SIZES))
$(OUT_DIR)/val2014_neuraltalk2_beam%.json: $(MODEL_FILE) \
	$(COCO_ROOT)/annotations/captions_val2014.json 
	mkdir -p $(OUT_DIR)
	CUDA_VISIBLE_DEVICES=$(GID) th eval.lua -model $< \
		-coco_json $(word 2,$^) \
		-output_json $@ -beam_size $* \
		-image_folder $(COCO_ROOT)/images/val2014 \
		-num_images -1 -language_eval 0 -dump_images 0 -dump_json 1

