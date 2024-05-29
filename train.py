"""Adversarial adaptation to train target encoder."""
import time

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from sklearn.metrics import f1_score, recall_score, precision_score, matthews_corrcoef, roc_auc_score

import param
from utils import make_cuda
from utils import save_model


def selection(args, encoder, classifier, data_loader):
    """Train classifier for source domain."""

    # setup criterion and optimizer
    optimizer = optim.Adam(list(encoder.parameters()) + list(classifier.parameters()),
                           lr=param.c_learning_rate)
    CELoss = nn.CrossEntropyLoss()

    # set train state for Dropout and BN layers
    encoder.train()
    classifier.train()

    for epoch in range(args.pre_epochs):
        for step, (reviews, mask, labels) in enumerate(data_loader):
            # Check if the batch size matches the expected batch size
            if reviews.size(0) != args.batch_size or mask.size(0) != args.batch_size or labels.size(
                    0) != args.batch_size:
                print(
                    f"Skipping batch {step + 1} as its size does not match the expected batch size of {args.batch_size}")
                continue

            reviews = make_cuda(reviews)
            mask = make_cuda(mask)
            labels = make_cuda(labels)

            # zero gradients for optimizer
            optimizer.zero_grad()

            # compute loss for discriminator
            feat = encoder(reviews, mask)
            preds = classifier(feat)
            cls_loss = CELoss(preds, labels)

            # optimize source classifier
            cls_loss.backward()
            optimizer.step()

            # print step info
            if (step + 1) % args.pre_log_step == 0:
                print("Epoch [%.2d/%.2d] Step [%.3d/%.3d]: cls_loss=%.4f"
                      % (epoch + 1,
                         args.pre_epochs,
                         step + 1,
                         len(data_loader),
                         cls_loss.item()))

    save_model(args, encoder, param.src_encoder_path)
    save_model(args, classifier, param.src_classifier_path)

    return encoder, classifier


def pretrain(args, encoder, classifier, data_loader):
    """Train classifier for source domain."""

    optimizer = optim.AdamW(list(encoder.parameters()) + list(classifier.parameters()),
                            lr=param.c_learning_rate)
    CELoss = nn.CrossEntropyLoss()

    encoder.train()
    classifier.train()

    for epoch in range(args.pre_epochs):
        for step, (reviews, mask, labels) in enumerate(data_loader):
            if reviews.size(0) != args.batch_size or mask.size(0) != args.batch_size or labels.size(
                    0) != args.batch_size:
                print(
                    f"Skipping batch {step + 1} as its size does not match the expected batch size of {args.batch_size}")
                continue

            reviews = make_cuda(reviews)
            mask = make_cuda(mask)
            labels = make_cuda(labels)

            optimizer.zero_grad()

            feat = encoder(reviews, mask)
            preds = classifier(feat)
            cls_loss = CELoss(preds, labels)

            cls_loss.backward()
            optimizer.step()

            if (step + 1) % args.pre_log_step == 0:
                print("Epoch [%.2d/%.2d] Step [%.3d/%.3d]: cls_loss=%.4f"
                      % (epoch + 1,
                         args.pre_epochs,
                         step + 1,
                         len(data_loader),
                         cls_loss.item()))

    save_model(args, encoder, param.src_encoder_path)
    save_model(args, classifier, param.src_classifier_path)

    return encoder, classifier


def adapt(args, src_encoder, tgt_encoder, discriminator,
          src_classifier, src_data_loader, tgt_data_train_loader, tgt_data_all_loader):
    """Train encoder for target domain."""

    src_encoder.eval()
    src_classifier.eval()
    tgt_encoder.train()
    discriminator.train()

    BCELoss = nn.BCELoss()
    KLDivLoss = nn.KLDivLoss(reduction='batchmean')
    optimizer_G = optim.Adam(tgt_encoder.parameters(), lr=param.d_learning_rate)
    optimizer_D = optim.Adam(discriminator.parameters(), lr=param.d_learning_rate)
    len_data_loader = min(len(src_data_loader), len(tgt_data_train_loader))

    for epoch in range(args.num_epochs):
        data_zip = enumerate(zip(src_data_loader, tgt_data_train_loader))
        for step, ((reviews_src, src_mask, _), (reviews_tgt, tgt_mask, _)) in data_zip:
            if reviews_src.size(0) < args.batch_size or reviews_tgt.size(0) < args.batch_size:
                print(f"Skipping batch {step + 1} as its size is smaller than {args.batch_size}")
                continue
            else:
                reviews_src = make_cuda(reviews_src)
                src_mask = make_cuda(src_mask)

                reviews_tgt = make_cuda(reviews_tgt)
                tgt_mask = make_cuda(tgt_mask)

                # zero gradients for optimizer
                optimizer_D.zero_grad()

                # extract and concat features
                with torch.no_grad():
                    feat_src = src_encoder(reviews_src, src_mask)
                feat_src_tgt = tgt_encoder(reviews_src, src_mask)
                feat_tgt = tgt_encoder(reviews_tgt, tgt_mask)
                feat_concat = torch.cat((feat_src_tgt, feat_tgt), 0)

                # predict on discriminator
                pred_concat = discriminator(feat_concat.detach())

                # prepare real and fake label
                label_src = make_cuda(torch.ones(feat_src_tgt.size(0))).unsqueeze(1)
                label_tgt = make_cuda(torch.zeros(feat_tgt.size(0))).unsqueeze(1)
                label_concat = torch.cat((label_src, label_tgt), 0)

                # compute loss for discriminator
                dis_loss = BCELoss(pred_concat, label_concat)
                dis_loss.backward()

                for p in discriminator.parameters():
                    p.data.clamp_(-args.clip_value, args.clip_value)
                # optimize discriminator
                optimizer_D.step()

                pred_cls = torch.squeeze(pred_concat.max(1)[1])
                acc = (pred_cls == label_concat).float().mean()

                # zero gradients for optimizer
                optimizer_G.zero_grad()
                T = args.temperature

                # predict on discriminator
                pred_tgt = discriminator(feat_tgt)

                # logits for KL-divergence
                with torch.no_grad():
                    src_prob = F.softmax(src_classifier(feat_src) / T, dim=-1)
                tgt_prob = F.log_softmax(src_classifier(feat_src_tgt) / T, dim=-1)
                kd_loss = KLDivLoss(tgt_prob, src_prob.detach()) * T * T

                # compute loss for target encoder
                gen_loss = BCELoss(pred_tgt, label_src)
                loss_tgt = args.alpha * gen_loss + args.beta * kd_loss
                loss_tgt.backward()
                torch.nn.utils.clip_grad_norm_(tgt_encoder.parameters(), args.max_grad_norm)
                # optimize target encoder
                optimizer_G.step()

                if (step + 1) % args.log_step == 0:
                    print("Epoch [%.2d/%.2d] Step [%.3d/%.3d]: "
                          "acc=%.4f g_loss=%.4f d_loss=%.4f kd_loss=%.4f"
                          % (epoch + 1,
                             args.num_epochs,
                             step + 1,
                             len_data_loader,
                             acc.item(),
                             gen_loss.item(),
                             dis_loss.item(),
                             kd_loss.item()))

        evaluate(tgt_encoder, src_classifier, tgt_data_all_loader)

    return tgt_encoder


def evaluate(encoder, classifier, data_loader):
    """Evaluation for target encoder by source classifier on target dataset."""
    # set eval state for Dropout and BN layers
    encoder.eval()
    classifier.eval()

    # init loss and accuracy
    loss = 0
    acc = 0

    # init additional metrics
    f1 = 0
    recall = 0
    precision = 0
    mcc = 0
    auc = 0

    # set loss function
    criterion = nn.CrossEntropyLoss()

    # evaluate network
    all_preds = []
    all_labels = []
    all_probs = []
    start = time.perf_counter()
    for (reviews, mask, labels) in data_loader:
        reviews = make_cuda(reviews)
        mask = make_cuda(mask)
        labels = make_cuda(labels)

        with torch.no_grad():
            feat = encoder(reviews, mask)
            preds = classifier(feat)
            probs = F.softmax(preds, dim=1)[:, 1].cpu().numpy()

        loss += criterion(preds, labels).item()
        pred_cls = preds.data.max(1)[1]
        acc += pred_cls.eq(labels.data).cpu().sum().item()

        all_preds.extend(pred_cls.cpu().numpy())
        all_labels.extend(labels.data.cpu().numpy())
        all_probs.extend(probs)

    # calculate additional metrics
    f1 = f1_score(all_labels, all_preds)
    recall = recall_score(all_labels, all_preds)
    precision = precision_score(all_labels, all_preds)
    mcc = matthews_corrcoef(all_labels, all_preds)

    auc = roc_auc_score(all_labels, all_probs)
    loss /= len(data_loader)
    acc /= len(data_loader.dataset)
    end = time.perf_counter()
    t = end - start
    print(
        "Avg Loss = %.4f, Avg Accuracy = %.4f, F1 = %.4f, Recall = %.4f, Precision = %.4f, MCC = %.4f, AUC = %.4f, time = %.4f" % (
            loss, acc, f1, recall, precision, mcc, auc, t))

    return acc, f1, recall, precision, mcc, auc, t
