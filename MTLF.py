import math
import random

import numpy as np
from numpy.linalg import norm
from scipy.linalg import cholesky


def compmedDist(X):
    """
    计算一组点的中位距离。

    参数：
    - X（numpy.ndarray）：输入数据矩阵，形状为（n_samples，n_features）。

    返回：
    - float：点的中位距离。

    该函数通过以下步骤计算一组点的中位距离：
    1. 如果样本数量（size1）大于500，则选择前500个样本；否则选择全部样本。
    2. 计算每个点的平方和，并构建矩阵G。
    3. 使用矩阵G计算两两点之间的距离矩阵dists。
    4. 将dists的对角线及以下部分置零。
    5. 将dists重塑为一维数组，去除其中大于零的值，计算其中位数。
    6. 返回中位距离的平方根作为最终结果。
    """
    size1 = X.shape[0]
    # if size1 > 500:
    #     Xmed = X[:500, :]
    #     size1 = 500
    # else:
    Xmed = X
    G = np.sum((Xmed * Xmed), axis=1)
    Q = np.tile(G.reshape(-1, 1), (1, size1))
    R = np.tile(G.reshape(size1, 1), (1, size1))
    dists = Q + R - 2 * Xmed.dot(Xmed.T)
    dists = dists - np.tril(dists)
    dists = dists.reshape(size1 ** 2, 1)
    sigma = np.sqrt(0.5 * np.median(dists[dists > 0]))
    return sigma


def kernel_Gaussian(x, c, sigma):
    """
    计算高斯核函数的值，用于衡量两组数据点之间的相似性。

    参数：
    - x（numpy.ndarray）：输入数据矩阵，形状为（n_features，n_samples）。
    - c（numpy.ndarray）：中心数据矩阵，形状为（n_features，n_centers）。
    - sigma（float）：高斯核函数的带宽参数。

    返回：
    - numpy.ndarray：高斯核矩阵，形状为（n_samples，n_centers）。

    该函数通过以下步骤计算高斯核函数：
    1. 获取输入数据矩阵和中心数据矩阵的维度。
    2. 计算输入数据矩阵每列的平方和（x2）和中心数据矩阵每列的平方和（c2）。
    3. 构建两个矩阵，其中一个矩阵的每列为中心数据矩阵的平方和，另一个矩阵的每行为输入数据矩阵的平方和。
    4. 计算两个矩阵的距离矩阵（distance2），其中包括两两点之间的距离。
    5. 根据高斯核函数的公式，利用带宽参数sigma计算每个点的相似性。
    6. 返回高斯核矩阵作为最终结果。
    """
    d, nx = x.shape
    _, nc = c.shape
    x2 = np.sum(x ** 2, axis=0)
    c2 = np.sum(c ** 2, axis=0)

    distance2 = np.tile(c2, (nx, 1)) + np.tile(x2.reshape(nx, 1), (1, nc)) - 2 * x.T.dot(c)
    return np.exp(-distance2 / (2 * sigma ** 2))


def ComputeDistanceExtremes(X, a, b):
    n = X.shape[0]
    num_trials = min(100, n * (n - 1) // 2)
    dists = np.zeros((num_trials, 1))

    # 随机选择样本对，计算欧氏距离
    for i in range(num_trials):
        j1 = random.randint(0, n - 1)
        j2 = random.randint(0, n - 1)
        dists[i] = np.sum((X[j1, :] - X[j2, :]) ** 2)

    # 计算直方图和累积频数
    f, c = np.histogram(dists, bins=100)
    cumulative_frequencies = np.cumsum(f)

    # 根据百分位数下限和上限找到对应的距离值
    l_index = np.searchsorted(cumulative_frequencies, a * num_trials / 100, side='right')
    u_index = np.searchsorted(cumulative_frequencies, b * num_trials / 100, side='right')

    # 计算距离范围的下限和上限值
    l = np.sqrt(dists[l_index][0])
    u = np.sqrt(dists[u_index][0])
    # l = np.percentile(c, a)
    # u = np.percentile(c, b)

    return l, u


def GetConstraints(y, num_constraints, l, u):
    m = len(y)
    C = np.zeros((num_constraints, 4))

    unique_labels = np.unique(y)
    num_unique_labels = len(unique_labels)

    if num_unique_labels == 1 or m < 2:
        # 如果数据集中只有一种类别或样本数量小于2，则返回空的约束矩阵
        return np.array([])

    for k in range(num_constraints):
        i, j = np.random.choice(m, size=2, replace=False)
        if y[i] == y[j]:
            C[k, :] = [i, j, 1, l]
        else:
            C[k, :] = [i, j, -1, u]

    index1 = np.where(C[:, 2] == 1)[0]
    index2 = np.where(C[:, 2] == -1)[0]
    if len(index2) > 0:
        C[index2, 2] = -len(index1) / len(index2)
    else:
        print("Unbalance Processing")

    return C


# def GetConstraints(y, num_constraints, l, u, max_attempts=100):
#     """
#     生成用于训练的约束样本对，其中约束条件基于类别标签和距离范围。
#
#     参数：
#     - y（numpy.ndarray）：样本的类别标签数组，形状为（m，1）。
#     - num_constraints（int）：所需的约束样本对数量。
#     - l（float）：距离范围的下限值。
#     - u（float）：距离范围的上限值。
#     - max_attempts（int）：最大尝试次数，用于避免无限循环。
#
#     返回：
#     - numpy.ndarray：包含约束样本对信息的数组，形状为（num_constraints，4）。
#       - 第一列：样本索引 i。
#       - 第二列：样本索引 j。
#       - 第三列：约束标签（1 表示相同类别，-1 表示不同类别）。
#       - 第四列：约束样本对的距离范围。
#
#     该函数通过以下步骤生成约束样本对：
#     1. 获取样本数量（m）。
#     2. 初始化约束样本对数组（C）。
#     3. 对于每个约束样本对，随机选择两个不同的样本索引（i 和 j）。
#     4. 根据所选样本的类别标签（y[i] 和 y[j]）设置约束标签和距离范围。
#     5. 如果不存在不同类别的样本对，则重新选择样本对，最多尝试 max_attempts 次。
#     6. 调整不同类别的约束样本对的标签以保持平衡。
#     7. 返回约束样本对数组（C）。
#     """
#     m = len(y)
#     C = np.zeros((num_constraints, 4))
#
#     # 生成约束样本对
#     for k in range(num_constraints):
#         attempts = 0
#         while attempts < max_attempts:
#             i, j = np.random.choice(m, size=2, replace=False)
#             if y[i] != y[j]:
#                 # 如果选择的样本不属于同一类别，则设置约束标签和距离范围，并跳出循环
#                 C[k, :] = [i, j, -1, u]
#                 break
#             attempts += 1
#         else:
#             # 如果尝试了 max_attempts 次仍然找不到不同类别的样本对，则跳过这次循环
#             continue
#
#     # 调整不同类别的约束样本对的标签以保持平衡
#     index1 = np.where(C[:, 2] == 1)[0]
#     index2 = np.where(C[:, 2] == -1)[0]
#
#     if len(index2) == 0:
#         return np.array([])
#
#     C[index2, 2] = -len(index1) / len(index2)
#
#     return C


def PCA_reduce(X, retain_dimensions):
    U, _, _ = np.linalg.svd(np.cov(X.T))
    reduced_X = X.dot(U[:, :retain_dimensions])
    return reduced_X


def RuLSIF(x_nu, x_de, x_re=None, alpha=0.5, sigma_list=None, lambda_list=None, b=100, fold=5):
    """
    RuLSIF (Relative to the Unbiased Samples Importance Weighting) 算法的实现。

    参数：
    - x_nu (numpy.ndarray): 目标域数据，维度为 (特征维度, 样本数)。
    - x_de (numpy.ndarray): 源域数据，维度为 (特征维度, 样本数)。
    - x_re (numpy.ndarray, optional): 用于计算预测误差的数据，维度为 (特征维度, 样本数)。默认为 None。
    - alpha (float, optional): RuLSIF算法的平衡参数，范围为 [0, 1]。默认为 0.5。
    - sigma_list (numpy.ndarray, optional): 高斯核函数的宽度参数列表。默认为 None。
    - lambda_list (numpy.ndarray, optional): 正则化参数列表。默认为 None。
    - b (int, optional): 用于计算核矩阵的子样本数。默认为 100。
    - fold (int, optional): 用于交叉验证的折数。默认为 5。

    返回：
    - PE (float): 预测误差。
    - wh_x_de (numpy.ndarray): 源域数据的权重向量。
    - wh_x_re (numpy.ndarray or int): 用于计算预测误差的数据的权重向量（或者当 x_re 为 None 时的占位符）。

    该函数实现了RuLSIF算法，包括高斯核矩阵的计算、交叉验证、优化参数选择、权重向量计算以及预测误差的计算。
    """
    np.random.seed(1)

    d, n_de = x_de.shape
    d_nu, n_nu = x_nu.shape

    is_disp = True if x_re is not None else False

    if alpha is None:
        alpha = 0.5

    if sigma_list is None:
        x = np.concatenate([x_nu, x_de], axis=1)
        med = compmedDist(x.T)
        sigma_list = med * np.array([0.6, 0.8, 1, 1.2, 1.4])
    elif np.any(sigma_list <= 0):
        raise ValueError("Gaussian width must be positive")

    if lambda_list is None or len(lambda_list) == 0:
        lambda_list = 10.0 ** np.array([-3, -2, -1, 0, 1])
    elif np.any(lambda_list < 0):
        raise ValueError("Regularization parameter must be non-negative")

    b = min(b, n_nu)
    n_min = min(n_de, n_nu)

    score_cv = np.zeros((len(sigma_list), len(lambda_list)))

    if len(sigma_list) == 1 and len(lambda_list) == 1:
        sigma_chosen = sigma_list[0]
        lambda_chosen = lambda_list[0]
    else:
        if fold != 0:
            cv_index_nu = np.random.permutation(n_nu)
            cv_split_nu = np.floor(np.arange(n_nu) * fold / n_nu).astype(int) + 1
            cv_index_de = np.random.permutation(n_de)
            cv_split_de = np.floor(np.arange(n_de) * fold / n_de).astype(int) + 1

        for sigma_index in range(len(sigma_list)):
            sigma = sigma_list[sigma_index]
            x_ce = x_nu[:, np.random.permutation(n_nu)[:b]]
            K_de = kernel_Gaussian(x_de, x_ce, sigma).T
            K_nu = kernel_Gaussian(x_nu, x_ce, sigma).T

            score_tmp = np.zeros((fold, len(lambda_list)))
            for k in range(1, fold + 1):
                Ktmp1 = K_de[:, cv_index_de[cv_split_de != k]]
                Ktmp2 = K_nu[:, cv_index_nu[cv_split_nu != k]]

                Ktmp = alpha / Ktmp2.shape[1] * Ktmp2 @ Ktmp2.T + (1 - alpha) / Ktmp1.shape[1] * Ktmp1 @ Ktmp1.T
                mKtmp = np.mean(K_nu[:, cv_index_nu[cv_split_nu != k]], axis=1)

                for lambda_index in range(len(lambda_list)):
                    lambda_val = lambda_list[lambda_index]
                    thetat_cv = mylinsolve(Ktmp + lambda_val * np.eye(b), mKtmp)
                    thetah_cv = thetat_cv  # max(0, thetat_cv)
                    score_tmp[k - 1, lambda_index] = alpha * np.mean(
                        (K_nu[:, cv_index_nu[cv_split_nu == k]].T @ thetah_cv) ** 2) / 2 \
                                                     + (1 - alpha) * np.mean(
                        (K_de[:, cv_index_de[cv_split_de == k]].T @ thetah_cv) ** 2) / 2 \
                                                     - np.mean(K_nu[:, cv_index_nu[cv_split_nu == k]].T @ thetah_cv)

            score_cv[sigma_index, :] = np.mean(score_tmp, axis=0)

        score_cv_tmp = np.min(score_cv, axis=1)
        sigma_chosen_index = np.argmin(score_cv_tmp)
        sigma_chosen = sigma_list[sigma_chosen_index]

        score_cv_tmp = np.min(score_cv, axis=0)
        lambda_chosen_index = np.argmin(score_cv_tmp)
        lambda_chosen = lambda_list[lambda_chosen_index]

    K_de = kernel_Gaussian(x_de, x_nu[:, :b], sigma_chosen).T
    K_nu = kernel_Gaussian(x_nu, x_nu[:, :b], sigma_chosen).T

    if is_disp:
        K_re = kernel_Gaussian(x_re, x_nu[:, :b], sigma_chosen).T

    Ktmp = alpha / K_nu.shape[1] * K_nu @ K_nu.T + (1 - alpha) / K_de.shape[1] * K_de @ K_de.T
    mKtmp = np.mean(K_nu, axis=1)
    thetat = mylinsolve(Ktmp + lambda_chosen * np.eye(b), mKtmp)
    thetah = thetat  # max(0, thetat)

    if is_disp:
        nu_re = K_re.T @ thetah
    else:
        nu_re = None  # Placeholder for nu_re when not computing x_re

    wh_x_de = (K_de.T @ thetah).flatten()
    wh_x_nu = (K_nu.T @ thetah).flatten()

    if is_disp:
        wh_x_re = (K_re.T @ thetah).flatten()
    else:
        wh_x_re = 0  # Placeholder for wh_x_re when not computing x_re

    PE = np.mean(wh_x_nu) - 1 / 2 * (alpha * np.mean(wh_x_nu ** 2) + (1 - alpha) * np.mean(wh_x_de ** 2)) - 1 / 2

    wh_x_de = np.maximum(0, wh_x_de)
    wh_x_re = np.maximum(0, wh_x_re)

    return PE, wh_x_de, wh_x_re


def pdf_Gaussian(x, mu, sigma):
    d, nx = x.shape
    tmp = (x - np.tile(mu, (1, nx))) / np.tile(sigma, (1, nx)) / np.sqrt(2)
    px = (2 * np.pi) ** (-d / 2) / np.prod(sigma) * np.exp(-np.sum(tmp ** 2, axis=0))
    return px


from scipy.sparse import issparse


def mylinsolve(A, b):
    """
    解线性方程组 Ax = b，其中 A 是系数矩阵，b 是右侧向量。

    参数：
    - A（numpy.ndarray 或 scipy.sparse.spmatrix）：系数矩阵。
    - b（numpy.ndarray）：右侧向量。

    返回：
    - x（numpy.ndarray）：解向量。

    该函数根据输入矩阵 A 是否为稀疏矩阵采用不同的解法。
    如果 A 是稀疏矩阵，则使用 Cholesky 分解进行求解；
    否则，使用标准的 Cholesky 分解。

    注意：此函数假设 A 是正定的，且输入是合法的。

    参数详解：
    - sflag（bool）：标志变量，指示输入的矩阵 A 是否为稀疏矩阵。
    - R（numpy.ndarray）：Cholesky 分解的上三角矩阵。
    - x（numpy.ndarray）：线性方程组的解向量。

    使用示例：
    ```python
    A = np.array([[4, 12, -16], [12, 37, -43], [-16, -43, 98]])
    b = np.array([1, 2, 3])

    x = mylinsolve(A, b)
    ```

    """
    sflag = issparse(A)

    if sflag:
        # 如果 A 是稀疏矩阵，使用 Cholesky 分解
        R = cholesky(A.todense(), lower=True, overwrite_a=True)
        x = np.linalg.solve(R.T, np.linalg.solve(R, b))
    else:
        # 如果 A 是密集矩阵，使用标准的 Cholesky 分解
        R = cholesky(A, lower=True, overwrite_a=True)
        x = np.linalg.solve(R.T, np.linalg.solve(R, b))

    return x


def KNN(y, X, M, k, Xt):
    """
    使用基于马氏距离的 k 近邻算法进行分类。

    参数：
    - y (numpy.ndarray): 训练样本的类标签。
    - X (numpy.ndarray): 训练样本矩阵。
    - M (numpy.ndarray): 中间矩阵，用于计算马氏距离。
    - k (int): 近邻数量。
    - Xt (numpy.ndarray): 测试样本矩阵。

    返回：
    - preds (numpy.ndarray): 预测的类标签。

    该函数基于训练样本和测试样本之间的马氏距离，通过 k 近邻算法进行分类。

    参数详解：
    - add1 (int): 类标签是否从0开始。若最小类标签为0，则将所有类标签加1以符合 k 近邻算法的要求。
    - n (int): 训练样本数。
    - m (int): 训练样本特征维度。
    - nt (int): 测试样本数。
    - K (numpy.ndarray): 马氏距离矩阵，K[i, j] 表示训练样本 X[i, :] 和测试样本 Xt[j, :] 之间的马氏距离。
    - l (numpy.ndarray): 训练集中每个样本的马氏距离。
    - lt (numpy.ndarray): 测试集中每个样本的马氏距离。
    - D (numpy.ndarray): 欧氏距离矩阵，用于备用计算。
    - preds (numpy.ndarray): 预测的类标签。
    """
    add1 = 0
    if np.min(y) == 0:
        y = y + 1
        add1 = 1

    n, m = X.shape
    nt, _ = Xt.shape

    # 计算训练样本和测试样本之间的马氏距离矩阵
    K = np.dot(X, M).dot(M.T).dot(Xt.T)

    # 初始化训练集和测试集的马氏距离
    l = np.zeros(n)
    lt = np.zeros(nt)

    # 计算训练集中每个样本的马氏距离
    for i in range(n):
        l[i] = np.dot(X[i, :], M).dot(M.T).dot(X[i, :])

    # 计算测试集中每个样本的马氏距离
    for i in range(nt):
        lt[i] = np.dot(Xt[i, :], M).dot(M.T).dot(Xt[i, :])

    # # 计算欧氏距离矩阵，用于备用计算
    # D = cdist(X, Xt, metric='euclidean') ** 2
    #
    # # 初始化预测结果矩阵
    # preds = np.zeros(nt)
    #
    # # 对每个测试样本执行 k 近邻分类
    # for i in range(nt):
    #     indices = np.argsort(D[:, i])
    #     counts = np.zeros(max(y))
    #
    #     # 统计 k 近邻中每个类别的数量
    #     for j in range(k):
    #         counts[y[indices[j]] - 1] += 1
    #
    #     # 预测结果为数量最多的类别
    #     preds[i] = np.argmax(counts) + 1
    #
    # # 若类标签从0开始，则还原为原始标签
    # if add1 == 1:
    #     preds = preds - 1

    return K


def demo(src_features, tgt_train_features, tgt_test_features, tgt_train_y, tgt_test_y, src_y):
    src_n = src_features.shape[0]
    tar_ntra = tgt_train_features.shape[0]
    tar_ntes = tgt_test_features.shape[0]
    dim = src_features.shape[1]

    # Init parameters
    print('Init parameters...')
    # k, C, dim, sigma, lamda, beta, gamma, gammaW
    P = [1, 100, 11, 1, 100, 1, 1e-6, 1e-7]
    param = initParam(P)

    A, wt = MTLF(param, src_features, tgt_train_features, tgt_test_features, tgt_train_y, tgt_test_y, src_y)

    return wt


def initParam(P):
    # k, C, dim, sigma, lamda, beta, gamma, gammaW
    P = [1, 100, 11, 1, 100, 1, 1e-6, 1e-7]
    param = {}
    param['k'] = P[0]
    param['num_constraints'] = P[1]
    param['dim'] = P[2]
    param['sigma'] = P[3]
    param['lamda'] = P[4]
    param['beta'] = P[5]
    param['gamma'] = P[6]
    param['gammaW'] = P[7]
    param['a'] = 5
    param['b'] = 95
    param['epsilon'] = 1e-7
    return param


def MTLF(param, src_features, tgt_train_features, tgt_test_features, tgt_train_y, tgt_test_y, src_y):
    a = param['a']
    b = param['b']
    num_constraints = param['num_constraints']
    k = param['k']
    dim = param['dim']

    source_data = src_features.cpu().detach().numpy()
    target_data = tgt_train_features.cpu().detach().numpy()

    X = np.vstack((source_data, target_data))

    tgt_train_y = tgt_train_y.cpu().detach().numpy()
    tgt_test_y = tgt_test_y.cpu().detach().numpy()
    source_labels = src_y.cpu().detach().numpy().flatten().reshape(-1, 1)
    target_labels = tgt_train_y.flatten().reshape(-1, 1)
    y = np.vstack((source_labels, target_labels))

    Xtest = tgt_test_features.cpu().detach().numpy()

    ntra_s_data = source_data.shape
    ntra_t_data = target_data.shape
    ntra_s = ntra_s_data[0]
    ntra_t = ntra_t_data[0]
    x_source = X[:ntra_s, :]
    x_target = np.vstack((X[ntra_s:ntra_s + ntra_t, :], Xtest))

    _, wh_x_source, _ = RuLSIF(x_target.T, x_source.T)
    wh_x_target = np.ones(Xtest.shape[0])
    wh_x_source = np.hstack((wh_x_source, wh_x_target))

    l, u = ComputeDistanceExtremes(X, a, b)

    C = GetConstraints(y, num_constraints, l, u)

    if len(C) == 0:
        wt = np.zeros(X.shape[0])
        K = KNN(y, X, np.eye(X.shape[1]), k, Xtest)
        return K, wt

    Xci = X[C[:, 0].astype(int), :]
    Xcj = X[C[:, 1].astype(int), :]

    d = X.shape[1]
    p = num_constraints
    w0 = wh_x_source
    sd_tra = X[:ntra_s, :]
    td_tra = X[ntra_s:ntra_s + ntra_t, :]
    A, result = optimization(C, w0, Xci, Xcj, param, sd_tra, td_tra)
    wt = result['wt']
    K = KNN(y, X, A, k, Xtest)
    return K, wt


def optimization(C, w0, Xci, Xcj, param, sd_tra, td_tra):

    epsilon = param['epsilon']
    sigma = param['sigma']
    lamda = param['lamda']
    beta = param['beta']
    gamma = param['gamma']
    gammaW = param['gammaW'] / sigma

    A0 = np.eye(Xci.shape[1])
    E = A0
    At = A0

    ns = sd_tra.shape[0]
    nt = td_tra.shape[0]
    e = np.zeros(ns + nt)
    e[:ns] = 1

    w0 = w0[:ns + nt]
    wt = w0

    iter = 0
    convA = 10000

    try:
        while convA > epsilon and iter < 100:
            sumA = np.zeros((Xci.shape[1], Xci.shape[1]))
            C = C.astype(int)
            pair_weights = wt[C[:, 0]] * wt[C[:, 1]] * C[:, 2]

            for i in range(Xci.shape[0]):
                vij = Xci[i, :] - Xcj[i, :]
                sumA = sumA + A0 @ np.outer(vij, vij) * pair_weights[i] * C[i, 2]

            At = At - gamma * (beta * sumA + 2 * A0)

            zeta = np.zeros(ns + nt)

            for k in range(Xci.shape[0]):
                i = C[k, 0]
                j = C[k, 1]
                deta_ij = C[k, 2]

                vij = Xci[k, :] - Xcj[k, :]
                vijA = vij @ At.T
                dij = vijA @ vijA.T

                zeta[i] = zeta[i] + wt[j] * dij * deta_ij
                zeta[j] = zeta[j] + wt[i] * dij * deta_ij

            xi = np.sign(np.maximum(0, -wt))
            dev1 = 2 * lamda * (wt - w0)
            dev2 = beta * zeta
            dev3 = sigma * (2 * (wt @ e - ns) * e + wt ** 2 * xi * e)

            w_dev = dev1 + dev2 + dev3
            wt = wt - gammaW * w_dev
            wt[ns:ns + nt] = 1

            if np.any(np.isnan(wt)):
                raise ValueError("NaN encountered in wt")

            convA = norm(At - A0)
            convW = norm(wt - w0)
            A0 = At
            iter += 1

    except (IndexError, ValueError, RuntimeWarning):
        wt = np.zeros_like(w0)
        result = {}
        result['At'] = At
        result['wt'] = wt
        result['w0'] = w0

    result = {}
    result['At'] = At
    result['wt'] = wt
    result['w0'] = w0

    return At, result
