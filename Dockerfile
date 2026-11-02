FROM python:3.13-slim-trixie AS base

ARG LAB_UID=1000
ARG LAB_GID=1000

RUN groupadd -g "${LAB_GID}" lab \
    && useradd -m -u "${LAB_UID}" -g lab lab

WORKDIR /workspace

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY requirements-torch.txt .
RUN pip install --no-cache-dir -r requirements-torch.txt \
        --index-url https://download.pytorch.org/whl/cpu

RUN python -c "import torch; assert torch.version.cuda is None, \
    f'CUDA detected: {torch.version.cuda}. Build must be CPU-only.'"

ENV PYTHONPATH=/workspace/src \
    TORCH_HOME=/workspace/.cache/torch

USER lab

CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--ServerApp.root_dir=/workspace"]
