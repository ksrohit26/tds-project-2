# ============================
# Base Image
# ============================
FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8

# ============================
# Create non-root user (UID 1000)
# ============================
RUN useradd -m -u 1000 user
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates curl unzip \
    # Playwright dependencies
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 libxrandr2 \
    libxfixes3 libpango-1.0-0 libcairo2 \
    # Tesseract OCR engine
    tesseract-ocr \
    # FFmpeg for audio processing (pydub)
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# ============================
# Install Python deps as root
# ============================
WORKDIR /home/user/app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir uv playwright && \
    playwright install --with-deps chromium

# ============================
# Switch to non-root user
# ============================
USER user

# FIX: Ensure all bins remain accessible
ENV HOME=/home/user PATH=/home/user/.local/bin:$PATH


COPY --chown=user . .

# ============================
# Expose port
# ============================
EXPOSE 7860
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]
