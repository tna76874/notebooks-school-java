FROM jupyter/scipy-notebook:python-3.8.13

USER root

ENV SETUP_STATUS="production"
ENV REPO_USER="tna76874"
ENV REPO_NAME="notebooks-school-chempy"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && apt-get install -y \
    ghostscript \
    software-properties-common \
    python3-tk

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get --quiet --assume-yes install curl git g++-10 gfortran-10 libgmp-dev binutils-dev bzip2 make cmake sudo \
    python3-dev python3-pip libboost-dev libgsl-dev liblapack-dev libsuitesparse-dev graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /tmp/sundials-5.5.0-build && \
    curl -Ls https://github.com/LLNL/sundials/releases/download/v5.5.0/sundials-5.5.0.tar.gz | tar xz -C /tmp && \
    FC=gfortran-10 cmake \
        -S /tmp/sundials-5.5.0 \
        -B /tmp/sundials-5.5.0-build \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_STATIC_LIBS=OFF \
        -DEXAMPLES_ENABLE_C=OFF \
        -DEXAMPLES_INSTALL=OFF \
        -DENABLE_LAPACK=ON \
        -DSUNDIALS_INDEX_SIZE=32 \
        -DENABLE_KLU=ON \
        -DKLU_INCLUDE_DIR=/usr/include/suitesparse \
        -DKLU_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu && \
    cmake --build /tmp/sundials-5.5.0-build && \
    cmake --build /tmp/sundials-5.5.0-build --target install && \
    rm -r /tmp/sundials-5.5.0*/ && \
    python3 -m pip install --upgrade-strategy=eager --upgrade pip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN add-apt-repository universe --yes --update && apt-get install -y \
    shc \
    gcc &\
    rm -rf /var/lib/apt/lists/*


COPY ./scripts/docker-entrypoint.sh /
COPY ./scripts/run_on_init /usr/local/bin/
COPY ./scripts/update_notebooks /usr/local/bin/
RUN chmod 775 /usr/local/bin/run_on_init
RUN chmod 775 /usr/local/bin/update_notebooks



ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN chmod 775 /docker-entrypoint.sh


USER ${NB_USER}


ENV PYCVODES_NO_LAPACK=1
ENV PYCVODES_NO_KLU=1 
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV MPLBACKEND=Agg
RUN git clone https://github.com/bjodah/chempy.git /tmp/chempy && \
    cd /tmp/chempy && \
    pip install --user -e .[all] && \
    mv /tmp/chempy/examples ${HOME}

COPY ./requirements.txt . 

RUN python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub &&\
    pip install jupyter_contrib_nbextensions ipywidgets &&\
    jupyter contrib nbextension install --user &&\
    jupyter nbextension enable varInspector/main && \
    rm -rf requirements.txt

RUN rm -rf ${HOME}/work

ENTRYPOINT ["/docker-entrypoint.sh"]