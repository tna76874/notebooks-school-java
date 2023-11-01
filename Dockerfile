FROM ghcr.io/tna76874/schoolnotebookjava:stable

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}

USER ${NB_USER}