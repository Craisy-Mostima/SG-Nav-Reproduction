import os

from transformers import AutoTokenizer, BertModel, BertTokenizer, RobertaModel, RobertaTokenizerFast


_DEFAULT_BERT_PATH = "/mnt/d/Habitat/models/bert-base-uncased"


def resolve_bert_model_path(text_encoder_type, bert_base_uncased_path=None):
    """Resolve GroundingDINO's BERT dependency to the local SG-Nav copy."""
    if text_encoder_type != "bert-base-uncased":
        return text_encoder_type

    local_path = (
        bert_base_uncased_path
        or os.environ.get("SGNAV_BERT_PATH")
        or _DEFAULT_BERT_PATH
    )
    if os.path.isfile(os.path.join(local_path, "config.json")):
        return local_path
    return text_encoder_type


def get_tokenlizer(text_encoder_type, bert_base_uncased_path):
    if not isinstance(text_encoder_type, str):
        # print("text_encoder_type is not a str")
        if hasattr(text_encoder_type, "text_encoder_type"):
            text_encoder_type = text_encoder_type.text_encoder_type
        elif text_encoder_type.get("text_encoder_type", False):
            text_encoder_type = text_encoder_type.get("text_encoder_type")
        else:
            raise ValueError(
                "Unknown type of text_encoder_type: {}".format(type(text_encoder_type))
            )
    
    model_path = resolve_bert_model_path(text_encoder_type, bert_base_uncased_path)
    print("final text_encoder_type: {}".format(model_path))
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    return tokenizer


def get_pretrained_language_model(text_encoder_type, bert_base_uncased_path):
    if text_encoder_type == "bert-base-uncased":
        model_path = resolve_bert_model_path(text_encoder_type, bert_base_uncased_path)
        return BertModel.from_pretrained(model_path)
    if text_encoder_type == "roberta-base":
        return RobertaModel.from_pretrained(text_encoder_type)
    raise ValueError("Unknown text_encoder_type {}".format(text_encoder_type))

def is_bert_model_use_local_path(bert_base_uncased_path):
    return bert_base_uncased_path is not None and len(bert_base_uncased_path) > 0
