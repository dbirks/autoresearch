FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

# Build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates python3 python3-pip build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy project first (cache layer)
COPY pyproject.toml uv.lock ./

# Install Python deps (installs torch with cu128)
RUN uv sync --frozen

# Copy the rest
COPY prepare.py train.py program.md ./

# Data cache mount point
VOLUME ["/root/.cache/autoresearch"]

# Default command
CMD ["uv", "run", "train.py"]