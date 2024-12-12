# base image
FROM registry.altlinux.org/alt/alt:p10

# set timezone
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install common system packages
RUN apt-get update && apt-get -y install wget git make build-essential

WORKDIR /home/fuzzer/
# get the source code of json-parser v1.1.0
RUN wget https://github.com/json-parser/json-parser/archive/refs/tags/v1.1.0.tar.gz && tar xf v1.1.0.tar.gz && rm -f v1.1.0.tar.gz

# install AFL++ fuzzer
RUN apt-get install -y AFLplusplus llvm15.0
ENV AFL_SKIP_CPUFREQ=1
ENV AFL_TRY_AFFINITY=1
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

# use llvm-15 by default
ENV ALTWRAP_LLVM_VERSION=15.0

ENTRYPOINT ["/bin/bash"]
