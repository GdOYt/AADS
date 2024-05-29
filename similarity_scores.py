import random

import numpy as np
import torch
from sklearn.model_selection import train_test_split, StratifiedKFold

from MTLF import demo
from prepare_data import load_data
from utils import get_data_loader, sol2Array, roberta_convert_examples_to_features

ground_truth_file = "Dataset/ground truth label.xlsx"
target_folder = "Dataset/Contract"
source_folder = "Dataset/Contract"


def set_seed(seed):
    random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.device_count() > 0:
        torch.cuda.manual_seed_all(seed)


def normalization(src_features_batch, tgt_train_features_batch, tgt_test_features_batch):
    concatenated_features = torch.cat([src_features_batch, tgt_train_features_batch, tgt_test_features_batch], dim=0)
    min_vals = torch.min(concatenated_features.float(), dim=0)[0]
    max_vals = torch.max(concatenated_features.float(), dim=0)[0]
    max_vals[max_vals == min_vals] += 1
    scaled_features = (concatenated_features - min_vals) / (max_vals - min_vals)
    src_features_batch_normalized = scaled_features[:src_features_batch.size(0)]
    tgt_train_features_batch_normalized = scaled_features[src_features_batch.size(0):src_features_batch.size(
        0) + tgt_train_features_batch.size(0)]
    tgt_test_features_batch_normalized = scaled_features[src_features_batch.size(0) + tgt_train_features_batch.size(0):]

    return src_features_batch_normalized, tgt_train_features_batch_normalized, tgt_test_features_batch_normalized


def get_source(args, target_project, source_projects, tokenizer):
    all_src_x = []
    all_src_y = []
    tgt_x = []
    tgt_y = []
    target_data_extracted = False

    for source_project in source_projects:
        if target_project != source_project:
            all_path_target, all_labels_target, all_path_source, all_labels_source = load_data(target_folder,
                                                                                               source_folder,
                                                                                               ground_truth_file,
                                                                                               target_project,
                                                                                               source_project)
            src_data = [sol2Array(path) for path in all_path_source]
            all_src_x.extend(src_data)
            all_src_y.extend(all_labels_source)

            if not target_data_extracted:
                tgt_x.extend([sol2Array(path) for path in all_path_target])
                tgt_y.extend(all_labels_target)
                target_data_extracted = True

    kf = StratifiedKFold(n_splits=10, shuffle=True, random_state=args.seed)
    fold_indices = [(train_index, test_index) for train_index, test_index in
                    kf.split(tgt_x, tgt_y)]

    chosen_fold_index = 0

    (train_index, test_index) = fold_indices[chosen_fold_index]
    tgt_test_x = [tgt_x[i] for i in train_index]
    tgt_train_x = [tgt_x[i] for i in test_index]
    tgt_test_y = [tgt_y[i] for i in train_index]
    tgt_train_y = [tgt_y[i] for i in test_index]

    src_features = roberta_convert_examples_to_features(all_src_x, all_src_y, 256, tokenizer)

    tgt_train_features = roberta_convert_examples_to_features(tgt_train_x, tgt_train_y, 256,
                                                              tokenizer)

    tgt_test_features = roberta_convert_examples_to_features(tgt_test_x, tgt_test_y, 256,
                                                             tokenizer)

    tgt_train_features_size = len(tgt_train_features)
    tgt_test_features_size = len(tgt_test_features)

    src_data_loader = get_data_loader(src_features, 32)

    tgt_train_loader = get_data_loader(tgt_train_features, batch_size=tgt_train_features_size)
    tgt_test_loader = get_data_loader(tgt_test_features, batch_size=tgt_test_features_size)

    tgt_train_batch = next(iter(tgt_train_loader))
    tgt_test_batch = next(iter(tgt_test_loader))
    tgt_train_features_batch, tgt_train_labels_batch = tgt_train_batch[0].cuda(), tgt_train_batch[2].cuda()
    tgt_test_features_batch, tgt_test_labels_batch = tgt_test_batch[0].cuda(), tgt_test_batch[2].cuda()

    src_x_selected = []
    src_y_selected = []
    index_offset = 0

    for src_batch in src_data_loader:
        src_features_batch, src_labels_batch = src_batch[0].cuda(), src_batch[2].cuda()

        src_features_batch, tgt_train_features_batch_nor, tgt_test_features_batch_nor = normalization(
            src_features_batch, tgt_train_features_batch, tgt_test_features_batch)
        wt = demo(src_features_batch, tgt_train_features_batch_nor, tgt_test_features_batch_nor,
                  tgt_train_labels_batch, tgt_test_labels_batch, src_labels_batch)

        batch_size_select = len(src_batch[0])
        max_index = min(32, batch_size_select)

        selected_indices = np.where(wt[:max_index] >= 0.85)[0]
        selected_indices = selected_indices + index_offset
        src_x_selected.extend([all_src_x[i] for i in selected_indices])
        src_y_selected.extend([all_src_y[i] for i in selected_indices])

        index_offset += max_index

    return src_x_selected, src_y_selected, tgt_x, tgt_y, chosen_fold_index
