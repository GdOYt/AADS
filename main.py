"""Main script for ADDA."""

import argparse
import csv
import random

import numpy as np
from imblearn.over_sampling import RandomOverSampler
import torch
import torch.nn.functional as F
from sklearn.model_selection import train_test_split
from torch import optim
from transformers import RobertaTokenizer

import param
from model import (Discriminator, RobertaEncoder, RobertaClassifier)
from prepare_data import load_data
from train import pretrain, adapt, evaluate
from utils import get_data_loader, init_model, sol2Array, roberta_convert_examples_to_features, make_cuda


def parse_arguments():
    # argument parsing
    parser = argparse.ArgumentParser(description="Specify Params for Experimental Setting")

    # 源域
    parser.add_argument('--src', type=str, default="blog",
                        choices=["books", "dvd", "electronics", "kitchen", "blog", "airline", "imdb"],
                        help="Specify src dataset")

    # 目标域
    parser.add_argument('--tgt', type=str, default="dvd",
                        choices=["books", "dvd", "electronics", "kitchen", "blog", "airline", "imdb"],
                        help="Specify tgt dataset")

    parser.add_argument('--pretrain', default=True, action='store_true',
                        help='Force to pretrain source encoder/classifier')

    parser.add_argument('--adapt', default=True, action='store_true',
                        help='Force to adapt target encoder')

    parser.add_argument('--seed', type=int, default=42,
                        help="Specify random state")

    parser.add_argument('--train_seed', type=int, default=42,
                        help="Specify random state")

    parser.add_argument('--load', default=False, action='store_true',
                        help="Load saved model")

    parser.add_argument('--model', type=str, default="solidity",
                        choices=["bert", "distilbert", "roberta", "distilroberta"],
                        help="Specify model type")

    parser.add_argument('--max_seq_length', type=int, default=128,
                        help="Specify maximum sequence length")

    parser.add_argument('--alpha', type=float, default=1.0,
                        help="Specify adversarial weight")

    parser.add_argument('--beta', type=float, default=1.0,
                        help="Specify KD loss weight")

    parser.add_argument('--temperature', type=int, default=20,
                        help="Specify temperature")

    parser.add_argument("--max_grad_norm", default=1.0, type=float,
                        help="Max gradient norm.")

    parser.add_argument("--clip_value", type=float, default=0.01,
                        help="lower and upper clip value for disc. weights")

    parser.add_argument('--batch_size', type=int, default=64,
                        help="Specify batch size")

    parser.add_argument('--pre_epochs', type=int, default=3,
                        help="Specify the number of epochs for pretrain")

    parser.add_argument('--pre_log_step', type=int, default=1,
                        help="Specify log step size for pretrain")

    parser.add_argument('--target_train_log_step', type=int, default=1,
                        help="Specify log step size for self-train")

    parser.add_argument('--num_epochs', type=int, default=5,
                        help="Specify the number of epochs for adaptation")

    parser.add_argument('--target_train_epochs', type=int, default=10,
                        help="Specify the number of epochs for self-training")

    parser.add_argument('--log_step', type=int, default=1,
                        help="Specify log step size for adaptation")

    return parser.parse_args()


def set_seed(seed):
    random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.device_count() > 0:
        torch.cuda.manual_seed_all(seed)


def main():
    args = parse_arguments()
    # argument setting
    print("=== Argument Setting ===")
    print("src: " + args.src)
    print("tgt: " + args.tgt)
    print("seed: " + str(args.seed))
    print("train_seed: " + str(args.train_seed))
    print("model_type: " + str(args.model))
    print("max_seq_length: " + str(args.max_seq_length))
    print("batch_size: " + str(args.batch_size))
    print("pre_epochs: " + str(args.pre_epochs))
    print("target_train_epochs: " + str(args.target_train_epochs))
    print("num_epochs: " + str(args.num_epochs))
    print("AD weight: " + str(args.alpha))
    print("KD weight: " + str(args.beta))
    print("temperature: " + str(args.temperature))
    set_seed(args.train_seed)

    tokenizer = RobertaTokenizer.from_pretrained('codeBERT-Solidity', local_files_only=True)

    ground_truth_file = "Dataset/ground truth label.xlsx"
    target_folder = "Dataset/Contract"
    source_folder = "Dataset/Contract"
    dataset_list = ['DE', 'OF', 'BN', 'TP', 'OF', 'RE', 'SE', 'UC']
    csv_filename = f"experiment_results_{str(args.temperature)}.csv"

    with open(csv_filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        header = ["SP", "TP", "SO_Acc", "SO_F1-Score",
                  "SO_Recall", "SO_Precision", "SO_MCC", "SO_AUC", "SO_t",
                  "DA_Acc", "DA_F1 Score",
                  "DA_Recall", "DA_Precision", "DA_MCC", "DA_AUC", "DA_t"]
        writer.writerow(header)

        for target_project in dataset_list:
            for source_project in dataset_list:
                if target_project != source_project:
                    print("target:" + target_project + "----------->" + "source:" + source_project)
                    all_path_target, all_labels_target, all_path_source, all_labels_source = load_data(target_folder,
                                                                                                       source_folder,
                                                                                                       ground_truth_file,
                                                                                                       target_project,
                                                                                                       source_project)
                    src_x = []
                    # preprocess data
                    print("=== Processing datasets ===")
                    for source_path in all_path_source:
                        x = sol2Array(source_path)
                        src_x.append(x)

                    src_y = all_labels_source

                    src_x, src_test_x, src_y, src_test_y = train_test_split(src_x, src_y,
                                                                            test_size=0.3,
                                                                            stratify=src_y,
                                                                            random_state=args.seed)

                    tgt_x = []
                    for target_path in all_path_target:
                        x = sol2Array(target_path)
                        tgt_x.append(x)

                    tgt_y = all_labels_target
                    tgt_train_x, tgt_test_x, tgt_train_y, tgt_test_y = train_test_split(tgt_x, tgt_y,
                                                                                        test_size=0.9,
                                                                                        stratify=tgt_y,
                                                                                        random_state=args.seed)

                    tgt_new_test_x, tgt_new_self_x, tgt_new_test_y, tgt_new_self_y = train_test_split(tgt_x, tgt_y,
                                                                                                      test_size=0.9,
                                                                                                      stratify=tgt_y,
                                                                                                      random_state=args.seed)

                    # Reshape the input data to 2D arrays
                    src_x = np.array(src_x).reshape(-1, 1)
                    tgt_train_x = np.array(tgt_train_x).reshape(-1, 1)
                    tgt_new_test_x = np.array(tgt_new_test_x).reshape(-1, 1)

                    # Perform oversampling on the training data
                    ros = RandomOverSampler(random_state=args.seed)
                    src_x_resampled, src_y_resampled = ros.fit_resample(src_x, src_y)
                    tgt_train_x_resampled, tgt_train_y_resampled = ros.fit_resample(tgt_train_x, tgt_train_y)
                    tgt_new_test_x_resampled, tgt_new_test_y_resampled = ros.fit_resample(tgt_new_test_x,
                                                                                          tgt_new_test_y)

                    src_x_resampled = src_x_resampled.flatten()
                    tgt_train_x_resampled = tgt_train_x_resampled.flatten()
                    tgt_new_test_x_resampled = tgt_new_test_x_resampled.flatten()

                    src_features = roberta_convert_examples_to_features(src_x_resampled, src_y_resampled,
                                                                        args.max_seq_length, tokenizer)
                    src_test_features = roberta_convert_examples_to_features(src_test_x, src_test_y,
                                                                             args.max_seq_length,
                                                                             tokenizer)
                    tgt_features = roberta_convert_examples_to_features(tgt_x, tgt_y, args.max_seq_length, tokenizer)
                    tgt_train_features = roberta_convert_examples_to_features(tgt_train_x_resampled,
                                                                              tgt_train_y_resampled,
                                                                              args.max_seq_length,
                                                                              tokenizer)
                    tgt_test_features = roberta_convert_examples_to_features(tgt_test_x, tgt_test_y,
                                                                             args.max_seq_length,
                                                                             tokenizer)
                    tgt_new_test_features = roberta_convert_examples_to_features(tgt_new_test_x_resampled,
                                                                                 tgt_new_test_y_resampled,
                                                                                 args.max_seq_length,
                                                                                 tokenizer)
                    tgt_new_features = roberta_convert_examples_to_features(tgt_new_self_x, tgt_new_self_y,
                                                                            args.max_seq_length,
                                                                            tokenizer)

                    src_data_loader = get_data_loader(src_features, args.batch_size)
                    src_data_eval_loader = get_data_loader(src_test_features, args.batch_size)
                    tgt_data_train_loader = get_data_loader(tgt_train_features, args.batch_size)
                    tgt_data_all_loader = get_data_loader(tgt_features, args.batch_size)
                    tgt_data_test_loader = get_data_loader(tgt_test_features, args.batch_size)
                    tgt_data_newtrain_loader = get_data_loader(tgt_new_test_features, args.batch_size)
                    tgt_data_newtest_loader = get_data_loader(tgt_new_features, args.batch_size)

                    src_encoder = RobertaEncoder().cuda()
                    tgt_encoder = RobertaEncoder().cuda()
                    src_classifier = RobertaClassifier().cuda()
                    discriminator = Discriminator().cuda()

                    if args.load:
                        src_encoder = init_model(args, src_encoder, restore=param.src_encoder_path)
                        src_classifier = init_model(args, src_classifier, restore=param.src_classifier_path)
                        tgt_encoder = init_model(args, tgt_encoder, restore=param.tgt_encoder_path)
                        discriminator = init_model(args, discriminator, restore=param.d_model_path)
                    else:
                        src_encoder = init_model(args, src_encoder)
                        src_classifier = init_model(args, src_classifier)
                        tgt_encoder = init_model(args, tgt_encoder)
                        discriminator = init_model(args, discriminator)

                    print("=== Training classifier for source domain ===")
                    if args.pretrain:
                        src_encoder, src_classifier = pretrain(
                            args, src_encoder, src_classifier, src_data_loader)

                    print("=== Evaluating classifier for source domain ===")
                    acc, f1, recall, precision, mcc, auc, t = evaluate(src_encoder, src_classifier, tgt_data_all_loader)
                    # result_file_path = "result.txt"
                    # with open(result_file_path, "a") as result_file:
                    #     result_file.write(
                    #         f"source_project: {source_project} -----> target_project: {target_project}, AUC: {auc:.4f}\n")
                    # evaluate(src_encoder, src_classifier, src_data_eval_loader)
                    # evaluate(src_encoder, src_classifier, tgt_data_all_loader)

                    for params in src_encoder.parameters():
                        params.requires_grad = False

                    for params in src_classifier.parameters():
                        params.requires_grad = False

                    print("=== Training encoder for target domain ===")
                    if args.adapt:
                        tgt_encoder.load_state_dict(src_encoder.state_dict())
                        # 使用tgt_test_x和tgt_test_y来训练目标域编码器
                        print("=== Training target encoder on target domain data ===")

                        tgt_encoder.train()
                        tgt_encoder_optimizer = optim.Adam(tgt_encoder.parameters(), lr=5e-5)

                        for epoch_target_train in range(args.target_train_epochs):
                            for step_target_train, (reviews_tgt_train, tgt_mask_train, labels_tgt_train) in enumerate(
                                    tgt_data_newtrain_loader):
                                if reviews_tgt_train.size(0) < args.batch_size:
                                    continue

                                reviews_tgt_train = make_cuda(reviews_tgt_train)
                                tgt_mask_train = make_cuda(tgt_mask_train)
                                labels_tgt_train = make_cuda(labels_tgt_train)

                                tgt_encoder_optimizer.zero_grad()

                                feat_tgt_train = tgt_encoder(reviews_tgt_train, tgt_mask_train)
                                preds_tgt_train = src_classifier(feat_tgt_train)

                                loss_tgt_train = F.cross_entropy(preds_tgt_train, labels_tgt_train)

                                loss_tgt_train.backward()
                                tgt_encoder_optimizer.step()

                                if (step_target_train + 1) % args.target_train_log_step == 0:
                                    print("Target Encoder Training Epoch [%.2d/%.2d] Step [%.3d/%.3d]: loss=%.4f"
                                          % (epoch_target_train + 1,
                                             args.target_train_epochs,
                                             step_target_train + 1,
                                             len(tgt_data_newtrain_loader),
                                             loss_tgt_train.item()))

                        evaluate(tgt_encoder, src_classifier, tgt_data_newtest_loader)

                        tgt_encoder = adapt(args, src_encoder, tgt_encoder, discriminator,
                                            src_classifier, src_data_loader, tgt_data_train_loader,
                                            tgt_data_test_loader)
                        # 使用tgt_test_x和tgt_test_y来训练目标域编码器
                        print("=== Secondary training ===")
                        tgt_encoder.train()
                        tgt_encoder_optimizer = optim.Adam(tgt_encoder.parameters(), lr=5e-5)

                        for epoch_target_train in range(args.target_train_epochs):
                            for step_target_train, (reviews_tgt_train, tgt_mask_train, labels_tgt_train) in enumerate(
                                    tgt_data_newtrain_loader):
                                if reviews_tgt_train.size(0) < args.batch_size:
                                    continue

                                reviews_tgt_train = make_cuda(reviews_tgt_train)
                                tgt_mask_train = make_cuda(tgt_mask_train)
                                labels_tgt_train = make_cuda(labels_tgt_train)

                                tgt_encoder_optimizer.zero_grad()

                                feat_tgt_train = tgt_encoder(reviews_tgt_train, tgt_mask_train)
                                preds_tgt_train = src_classifier(feat_tgt_train)

                                loss_tgt_train = F.cross_entropy(preds_tgt_train, labels_tgt_train)

                                loss_tgt_train.backward()
                                tgt_encoder_optimizer.step()

                                if (step_target_train + 1) % args.target_train_log_step == 0:
                                    print("Target Encoder Training Epoch [%.2d/%.2d] Step [%.3d/%.3d]: loss=%.4f"
                                          % (epoch_target_train + 1,
                                             args.target_train_epochs,
                                             step_target_train + 1,
                                             len(tgt_data_newtrain_loader),
                                             loss_tgt_train.item()))

                        evaluate(tgt_encoder, src_classifier, tgt_data_newtest_loader)
                    print("=== Evaluating classifier for encoded target domain ===")
                    print(">>> source only <<<")
                    src_only_results = evaluate(src_encoder, src_classifier, tgt_data_test_loader)
                    print(">>> domain adaption <<<")
                    adaption_results = evaluate(tgt_encoder, src_classifier, tgt_data_test_loader)

                    row = [source_project, target_project] + list(src_only_results) + list(adaption_results)
                    writer.writerow(row)


if __name__ == '__main__':
    main()
