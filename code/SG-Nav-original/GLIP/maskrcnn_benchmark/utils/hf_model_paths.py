"""Resolve Hugging Face model names to the local SG-Nav model store."""

import os


_DEFAULT_BERT_PATH = "/mnt/d/Habitat/models/bert-base-uncased"


def resolve_hf_model_path(model_name):
    """Use the local BERT copy when available, otherwise keep the model name."""
    if model_name == "bert-base-uncased":
        local_path = os.environ.get("SGNAV_BERT_PATH", _DEFAULT_BERT_PATH)
        if os.path.isfile(os.path.join(local_path, "config.json")):
            return local_path
    return model_name
