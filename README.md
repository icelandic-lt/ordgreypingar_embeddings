# Embeddings / Greypingar

![Python](https://img.shields.io/badge/Python-3.8+-blue?logo=python&logoColor=white)
![CI Status](https://img.shields.io/badge/CI-[unavailable]-red)
![Docker](https://img.shields.io/badge/Docker-[unavailable]-red)

## Overview
- **Language:** Python
- **Language Version/Dialect:**
  - Python: 3.8+
  - C: (for GloVe)
- **Category:** [Support Tools](https://github.com/icelandic-lt/icelandic-lt/blob/main/doc/st.md)
- **Domain:** Generic
- **Status:** Experimental

## Description

This repository houses evaluation datasets for semantic and morphological relatedness in the Icelandic language.

More specifically, users of this repository can perform any or all of the three following actions:

1. Generate the necessary input files for training embeddings.
2. Train embeddings using any of the three available methods: word2vec, fastText, or GloVe.
3. Evaluate the embeddings using either of two different datasets: MSL or IceBATS.

Please note that training and evaluation often require a sizeable amount of memory (plus, when using GloVe, a hefty amount of hard drive space), and may take a long time. If you're only testing your code, you may want to try preparing smaller input files rather than utilizing the full extent of the IGC, and to set the epoch hyperparameter to a low value for briefer training sessions. If you're only performing evaluation and don't need to create or alter embeddings, we recommend that you follow the approach in our code of using only vector files rather than the model files in their entirety.

## Input file generation
The data preparation scripts work with [Icelandic Gigaword Corpus 1 (ICG1) (20.05)](http://hdl.handle.net/20.500.12537/41) and [Icelandic Gigaword Corpus 2 (ICG2) (20.05)](http://hdl.handle.net/20.500.12537/33). Newer versions of the corpus use an incompatible format. The code assumes that the IGC data is available in the subdirectory `./RMH`.

Data preparation code is located in the [./prep_code_general](./prep_code_general) directory. Use `get_lemmatized_sents.py` to create an input file with lemmatized data, or `get_original_sents.py` to create an input file without lemmatizing the data.

If you intend to use GloVe to train embeddings, you will subsequently need to run `make_oneline.py` on that input file.

## Training embeddings

The code for each method is located in an eponymous folder. Note that it will not only train embeddings, but also run a full evaluation of them right after. A brief guide on how to skip the evaluation process may be found below.

The code generally assumes that your input file, and the evaluation datafiles, will be located in the same directory as the Python files you're running. Each folder also has a `test_analogies.py` file which contains functionality for evaluation. If you only intend to train embeddings and not test them, you can remove calls on functions from this file.

For [word2vec](./word2vec) and [fastText](./fastText), you simply need to run their respective `train_w2v.py` or `gsft.py` Python files. Their structure is almost identical. If you wish to skip the evaluation part, comment out everything in the `train_model()` function that comes after the `mod_vectors.save()` call.

[GloVe](./GloVe), however, requires you to run the `glove_train.sh` Bash script, which in turn will call on `glove_msl.py`. The actual training, in fact, is performed entirely inside the Bash script, with the Python file used only for evaluation. If you wish only to train, open the `glove_train.sh` script and comment out the two lines near the end that contain a reference to `glove_msl.py`.


## Evaluating the embeddings

As noted above, the evaluation code for word2vec and fastText is situated in the latter half of the train_model() functions of their respective Python files, following the `mod_vectors.save()` call. If you don't wish to run a full training session, simply comment out the training code - that is, the call on a training function, and the call to save the resulting file - and go directly to the load function that follows.

For GloVe, however, it's the Bash script that performs the training, and then right at the end calls on a Python file to run the evaluation. You'll thus want to either comment out the majority of the Bash script code, or simply execute the Python script yourself according to the syntax of the very last line (the one containing a reference to `glove_msl.py`) in the Bash script.

There are two separate evaluation options: [MSL](./MSL), which is based on Multi-SimLex, and [IceBATS](./IceBATS), which is based on the Bigger Analogy Test Set. Each option branches into multiple sub-options. You do not need to execute both evaluation options, and can comment out the one you opt not to run.

In theory, you do not even need to execute every sub-option of your chosen evaluation paradigm, but be aware that excluding sub-options may mean your results are no longer comparable to those of previous MSL or BATS evaluations. The details of each sub-option are explained in the published articles on the original MSL and BATS datasets.

As mentioned at the start of this document, please note that just as with the training processes, the evaluation code can be somewhat demanding on your hardware, particularly in terms of primary memory. We have tried to ameliorate this factor by limiting the number of variables used to store the entire set of vectors. If your program repeatedly fails to complete - for example, if it receives a kill signal from your OS - or if your results files are empty after an apparently successful run, you may want to perform test runs with embeddings built from a smaller corpus subset, or with only some of sub-options.

### Installation

Start by cloning this repository recursively to populate the `GloVe` submodule:

``` shell
git clone --recursive https://github.com/icelandic-lt/ordgreypingar_embeddings.git
cd ordgreypingar_embeddings
```

Each method of training embeddings requires the installation of different dependencies. For `fastText` and `word2vec` you will need the `gensim` Python package.

The Python dependencies are listed in `requirements.txt` and can be installed as such, by creating a virtual environment and using `pip`:

``` shell
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

Using GloVe additionally requires GNU Make and GCC.
