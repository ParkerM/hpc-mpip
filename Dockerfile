FROM gtomscs/hpc

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        libunwind8 libunwind8-dbg libunwind8-dev \
	    cfortran f2c fcc ftnchek gfortran libgfortran3-dbg \
	    libiberty-dev \
	    wget

RUN cd /tmp && \
    wget https://github.com/LLNL/mpiP/archive/3.4.1.tar.gz -O mpip.tar.gz && \
    tar -xzf mpip.tar.gz && rm mpip.tar.gz && \
    cd mpi* && \
    mkdir -p /usr/local/tools/mpiP && ./configure --prefix=/usr/local/tools/mpiP && \
    LOGNAME=idk.log make && make install && \
    cd / && rm -rf /tmp/*

ENTRYPOINT ['/bin/bash']
