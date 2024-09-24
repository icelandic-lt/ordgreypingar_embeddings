#!/bin/bash
set -e

# Makes programs, trains a GloVe model, then evaluates it.

make

CORPUS=all_sentences_lower_lemmatized_oneline.txt
VOCAB_FILE=vocab_rmh_glove.txt
COOCCURRENCE_FILE=cooccurrence.bin
COOCCURRENCE_SHUF_FILE=cooccurrence.shuf.bin
BUILDDIR=build
SAVE_FILE=vectors_rmh_glove
VERBOSE=2
MEMORY=4.0
VOCAB_MIN_COUNT=10
VECTOR_SIZE=300
MAX_ITER=10
WINDOW_SIZE=10
BINARY=2
NUM_THREADS=8
X_MAX=40
PYTHON=python3

echo
echo "$ $BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE"
$BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE
echo "$ $BUILDDIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE"
$BUILDDIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE
echo "$ $BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE"
$BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE
echo "$ $BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE"
$BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE
if [ "$CORPUS" = 'all_sentences_lower_oneline.txt' ]; then
   echo "$PYTHON -m gensim.scripts.glove2word2vec --input vectors_rmh_glove.txt --output vectors_rmh_glove_w2v.txt"
   $PYTHON -m gensim.scripts.glove2word2vec --input vectors_rmh_glove.txt --output vectors_rmh_glove_w2v.txt
   echo "$ $PYTHON glove_msl.py $VOCAB_MIN_COUNT $VECTOR_SIZE $MAX_ITER $WINDOW_SIZE $X_MAX"
   $PYTHON glove_msl.py $VOCAB_MIN_COUNT $VECTOR_SIZE $MAX_ITER $WINDOW_SIZE $X_MAX
fi
