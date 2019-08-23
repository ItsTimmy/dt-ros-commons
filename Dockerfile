# parameters
ARG REPO_NAME="dt-ros-commons"

ARG ARCH=arm32v7
ARG MAJOR=devel20
ARG ROS_DISTRO=kinetic
ARG BASE_TAG=${MAJOR}-${ARCH}

# define base image
FROM duckietown/dt-ros-${ROS_DISTRO}-base:${BASE_TAG}

# configure environment
ENV SOURCE_DIR /code
ENV CATKIN_WS_DIR "${SOURCE_DIR}/catkin_ws"
ENV ROS_LANG_DISABLE gennodejs:geneus:genlisp
ENV READTHEDOCS True
WORKDIR "${CATKIN_WS_DIR}"

# define repository path
ARG REPO_PATH="${CATKIN_WS_DIR}/src/${REPO_NAME}"
WORKDIR "${REPO_PATH}"

# create repo directory and copy the source code
RUN mkdir -p "${REPO_PATH}"
COPY . "${REPO_PATH}/"

# install apt dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    $(awk -F: '/^[^#]/ { print $1 }' dependencies-apt.txt | uniq) \
  && rm -rf /var/lib/apt/lists/*

# install python dependencies
RUN pip install -r ${REPO_PATH}/dependencies-py.txt

# build packages
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
  catkin build \
    --workspace ${CATKIN_WS_DIR}/

# configure entrypoint
ENTRYPOINT ["entrypoint.sh"]

LABEL maintainer="Andrea F. Daniele (afdaniele@ttic.edu)"
