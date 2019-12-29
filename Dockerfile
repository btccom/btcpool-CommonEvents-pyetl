FROM ubuntu:18.04
MAINTAINER Yihao Peng yihao.peng@bitmain.com

ENV LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/local/lib:/usr/local/cuda/lib64/:/opt/hadoop/lib/native

ARG APT_MIRROR_URL=http://mirrors.aliyun.com/ubuntu/

RUN sed -i "s#http://archive.ubuntu.com/ubuntu/#${APT_MIRROR_URL}#g" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y git wget libevent-pthreads-2.1-6 python3 python3-dev python3-setuptools python3-pip \
        build-essential zlib1g-dev libssl-dev libsasl2-dev liblz4-dev libsnappy1v5 libsnappy-dev \
        liblzo2-2 liblzo2-dev \
    && apt-get clean \
    && apt-get autoremove -y

# Build librdkafka static library
RUN cd /tmp && wget https://github.com/edenhill/librdkafka/archive/v1.3.0.tar.gz && \
    [ $(sha256sum v1.3.0.tar.gz | cut -d " " -f 1) = "465cab533ebc5b9ca8d97c90ab69e0093460665ebaf38623209cf343653c76d2" ] && \
    tar zxf v1.3.0.tar.gz && cd librdkafka-1.3.0 && \
    ./configure && make -j${nproc} && make install && rm -rf /tmp/*

RUN pip3 install python-snappy python-lzo brotli kazoo requests confluent-kafka confluent-kafka[avro] numpy pandas cython numba fastparquet

ADD pyetl.py /app/
ADD bin/ /app/bin/

CMD ["/app/bin/maprpyparqetl.sh"]
