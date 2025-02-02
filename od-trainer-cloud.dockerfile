#base image
FROM gcr.io/deeplearning-platform-release/pytorch-gpu
RUN apt update && \
   apt install --no-install-recommends -y build-essential gcc wget curl python3.9 && \
   apt clean && rm -rf /var/lib/apt/lists/*


RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /root
# Make sure gsutil will use the default service account
# RUN echo '[GoogleCompute]\nservice_account = default' > /etc/boto.cfg

RUN pip install dvc 'dvc[gs]'

COPY requirements.txt /tmp/requirements.txt
COPY setup.py setup.py
RUN pip install --upgrade pip setuptools wheel
RUN python3.9 -m pip install -r /tmp/requirements.txt --no-cache-dir

COPY src/ src/
COPY .git/ .git/
COPY .dvc/config .dvc/config
COPY data.dvc data.dvc

COPY cloud-docker-training.sh cloud-docker-training.sh
ENTRYPOINT ["./cloud-docker-training.sh"]
