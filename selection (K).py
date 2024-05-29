import argparse
import csv
import random

import numpy as np
import torch
import torch.nn.functional as F
from imblearn.over_sampling import RandomOverSampler
from sklearn.model_selection import train_test_split, StratifiedKFold
from torch import optim
from transformers import RobertaTokenizer

import param
import similarity_scores
from model import (Discriminator, RobertaEncoder, RobertaClassifier)
from train import pretrain, adapt, evaluate
from utils import get_data_loader, init_model, roberta_convert_examples_to_features, make_cuda


def parse_arguments():
    parser = argparse.ArgumentParser(description="Specify Params for Experimental Setting")

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

    parser.add_argument('--model', type=str, default="codeBERT",
                        choices=["bert", "distilbert", "roberta", "distilroberta"],
                        help="Specify model type")

    parser.add_argument('--max_seq_length', type=int, default=128,
                        help="Specify maximum sequence length")

    parser.add_argument('--alpha', type=float, default=1.0,
                        help="Specify adversarial weight")

    parser.add_argument('--beta', type=float, default=1.0,
                        help="Specify KD loss weight")

    parser.add_argument('--temperature', type=int, default=10,
                        help="Specify temperature")

    parser.add_argument("--max_grad_norm", default=1.0, type=float,
                        help="Max gradient norm.")

    parser.add_argument("--clip_value", type=float, default=0.01,
                        help="lower and upper clip value for disc. weights")

    parser.add_argument('--batch_size', type=int, default=32,
                        help="Specify batch size")

    parser.add_argument('--pre_epochs', type=int, default=2,
                        help="Specify the number of epochs for pretrain")

    parser.add_argument('--pre_log_step', type=int, default=1,
                        help="Specify log step size for pretrain")

    parser.add_argument('--target_train_log_step', type=int, default=1,
                        help="Specify log step size for self-train")

    parser.add_argument('--num_epochs', type=int, default=2,
                        help="Specify the number of epochs for adaptation")

    parser.add_argument('--target_train_epochs', type=int, default=2,
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
    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("GPU available. Using GPU.")
    else:
        device = torch.device("cpu")
        print("GPU not available. Using CPU.")
    # argument setting
    print("=== Argument Setting ===")
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

    tokenizer = RobertaTokenizer.from_pretrained('codeBERT', local_files_only=True)

    dataset_list = ['OF', 'DE', 'SE', 'RE', 'UC', 'TP', 'BN', 'EF']

    csv_filename = (f"adjust-85.csv")

    kf = StratifiedKFold(n_splits=10, shuffle=True, random_state=args.seed)
    with open(csv_filename, mode='a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        header = ["TP",
                  "DA_Acc", "DA_F1 Score",
                  "DA_Recall", "DA_Precision", "DA_MCC", "DA_AUC", "DA_t"]
        writer.writerow(header)

        for target_project in dataset_list:
            print("--------------------------{}------------------------------".format(target_project))
            source_selected, source_label, target_selected, target_label, chosen_fold_index = similarity_scores.get_source(
                args,
                target_project,
                dataset_list,
                tokenizer)

            fold_indices = [(train_index, test_index) for train_index, test_index in
                            kf.split(target_selected, target_label)]

            chosen_fold_index = chosen_fold_index

            (train_index, test_index) = fold_indices[chosen_fold_index]
            tgt_new_test_x = [target_selected[i] for i in train_index]
            tgt_new_self_x = [target_selected[i] for i in test_index]
            tgt_new_test_y = [target_label[i] for i in train_index]
            tgt_new_self_y = [target_label[i] for i in test_index]

            print(f"Chosen Fold {chosen_fold_index + 1} as training set:")
            print("---------------------BERT begin!-------------------------")

            print(target_project)

            src_train_x, src_test_x, src_train_y, src_test_y = train_test_split(source_selected, source_label,
                                                                                test_size=0.3,
                                                                                stratify=source_label,
                                                                                random_state=args.seed)

            source_selected = np.array(source_selected).reshape(-1, 1)
            tgt_new_self_x = np.array(tgt_new_self_x).reshape(-1, 1)

            ros = RandomOverSampler(random_state=args.seed)
            src_x_resampled, src_y_resampled = ros.fit_resample(source_selected, source_label)
            tgt_new_self_x_resampled, tgt_new_self_y_resampled = ros.fit_resample(tgt_new_self_x,
                                                                                  tgt_new_self_y)

            src_x_resampled = src_x_resampled.flatten()
            # tgt_train_x_resampled = tgt_train_x_resampled.flatten()
            tgt_new_self_x_resampled = tgt_new_self_x_resampled.flatten()
            # print("------------------src_features:")
            src_features = roberta_convert_examples_to_features(src_x_resampled, src_y_resampled,
                                                                args.max_seq_length, tokenizer)
            # print("------------------src_features_test:")
            src_test_features = roberta_convert_examples_to_features(src_test_x, src_test_y,
                                                                     args.max_seq_length,
                                                                     tokenizer)
            # print("------------------tgt_features:")
            tgt_features = roberta_convert_examples_to_features(target_selected, target_label, args.max_seq_length,
                                                                tokenizer)

            tgt_new_test_features = roberta_convert_examples_to_features(tgt_new_self_x_resampled,
                                                                         tgt_new_self_y_resampled,
                                                                         args.max_seq_length,
                                                                         tokenizer)
            tgt_new_features = roberta_convert_examples_to_features(tgt_new_test_x, tgt_new_test_y,
                                                                    args.max_seq_length,
                                                                    tokenizer)

            src_data_loader = get_data_loader(src_features, args.batch_size)
            src_data_eval_loader = get_data_loader(src_test_features, args.batch_size)
            tgt_data_all_loader = get_data_loader(tgt_features, args.batch_size)
            tgt_data_newtrain_loader = get_data_loader(tgt_new_test_features, args.batch_size)
            tgt_data_newtest_loader = get_data_loader(tgt_new_features, args.batch_size)

            src_encoder = RobertaEncoder().to(device)
            tgt_encoder = RobertaEncoder().to(device)
            src_classifier = RobertaClassifier().to(device)
            discriminator = Discriminator().to(device)

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

            src_encoder = src_encoder.to(device)
            src_classifier = src_classifier.to(device)
            tgt_encoder = tgt_encoder.to(device)
            discriminator = discriminator.to(device)

            print("=== Training classifier for source domain ===")
            if args.pretrain:
                src_encoder, src_classifier = pretrain(
                    args, src_encoder, src_classifier, src_data_loader)

            print("=== Evaluating classifier for source domain ===")
            evaluate(src_encoder, src_classifier, tgt_data_all_loader)
            evaluate(src_encoder, src_classifier, src_data_eval_loader)

            for params in src_encoder.parameters():
                params.requires_grad = False

            for params in src_classifier.parameters():
                params.requires_grad = False

            print("=== Training encoder for target domain ===")
            if args.adapt:
                tgt_encoder.load_state_dict(src_encoder.state_dict())

                print("=== Training target encoder on target domain data ===")

                tgt_encoder.train()
                tgt_encoder_optimizer = optim.AdamW(tgt_encoder.parameters(), lr=5e-5, weight_decay=1e-5)

                for epoch_target_train in range(1):
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
                print("=== Domain adaption ===")
                tgt_encoder = adapt(args, src_encoder, tgt_encoder, discriminator,
                                    src_classifier, src_data_loader, tgt_data_all_loader,
                                    tgt_data_newtest_loader)

                print("=== Second training target encoder ===")
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
                    print(">>> domain adaption <<<")
                    adaption_results = evaluate(tgt_encoder, src_classifier, tgt_data_newtest_loader)
                    row = [target_project] + list(adaption_results)
                    writer.writerow(row)


if __name__ == '__main__':
    main()
