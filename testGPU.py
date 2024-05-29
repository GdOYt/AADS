import torch.cuda

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
# print(torch.version.cuda)
print("Number of available GPUs:", torch.cuda.device_count())
