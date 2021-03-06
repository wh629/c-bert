#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:2
#SBATCH --partition=v100_sxm2_4,p40_4,p100_4
#SBATCH --mem=32000
#SBATCH --time=12:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=wh629@nyu.edu
#SBATCH --job-name="16b/2gpu/10k/base"
#SBATCH --output=<path>/<name>.out

module purge
module load anaconda3/5.3.1
module load cuda/10.0.130
module load gcc/6.3.0

# Replace with your NetID
NETID=wh629
source activate /scratch/${NETID}/nlu/env

# Set project working directory
PROJECT=/scratch/${NETID}/nlu/projects/meta

# Set arguments
STUDY_NAME=baseline_SQuAD_16b_2gpu_10k_3e-5   # name of experiment
N_TRIALS=10000                     # number of fine tuning steps
LOGGING_STEPS=1000                 # number of steps between logging steps for experiment
SAVE_STEPS=1000                    # number of steps to test for best weights
VERBOSE_STEPS=100                 # number of steps to record results to run log
SAVE_DIR=${PROJECT}/results       # directory for results
DATA_DIR=${PROJECT}/data          # directory for data
MODEL=bert-base-uncased           # name of model from Huggingface
BATCH=24                          # batch-size, will be split over number of GPUs
SEED=42                           # seed for experiment, Huggingface default is 42
MAX_SEQ=384                       # maximum sequence length for input
DOC_STRIDE=128                    # stride between windows for Huggingface sliding window
LR=0.00003                        # learning rate
CURRIC=SQuAD
RLN_WEIGHTS=<absolute file name for weights>



cd ${PROJECT}
python ./meta-bert/code/main.py \
    --experiment ${STUDY_NAME} \
	--fine_tune_steps ${N_TRIALS} \
	--logging_steps ${LOGGING_STEPS} \
	--save_steps ${SAVE_STEPS} \
	--verbose_steps ${VERBOSE_STEPS} \
    	--save_dir ${SAVE_DIR} \
    	--data_dir ${DATA_DIR} \
    	--model ${MODEL} \
	--batch_size ${BATCH} \
	--seed ${SEED} \
	--learning_rate ${LR} \
	--max_seq_length ${MAX_SEQ} \
	--doc_stride ${DOC_STRIDE} \
	--continual_curriculum ${CURRIC} \
	--do_lower_case \
	--load_rln \
	--rln_weights ${RLN_WEIGHTS} \
	--freeze_embeddings
	
