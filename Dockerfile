# Use the official ROS Noetic base image
FROM ros:noetic-ros-core-focal

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV TZ=Etc/UTC

# Setup non-root user and its workspace
ARG USER_NAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g $USER_GID $USER_NAME && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /workspace && chown $USER_NAME:$USER_NAME /workspace

USER $USER_NAME
WORKDIR /workspace

# Switch to root user to install packages
USER root

# Install essential dependencies
RUN apt update && apt install -y \
    locales \
    curl \
    lsb-release \
    git \
    vim \
    python3-pip \
    python-is-python3 \
    cmake \
    make \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Setup Locale
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    dpkg-reconfigure locales

# Install ROS dependencies
RUN apt update && apt install -y \
    python3-rosdep && \
    rosdep init && \
    rosdep update

# Setup automatic ROS sourcing for the user
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/$USER_NAME/.bashrc

# Install Python packages
RUN pip install --no-cache-dir autopep8 flake8

# Switch back to non-root user
USER $USER_NAME

# Setup Tini as the init system to manage the container processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Keeps the container running in idle mode after startup
CMD ["tail", "-f", "/dev/null"]

# -----------------------------------------------------------------------
# BARN Challenge Specific Setup
# -----------------------------------------------------------------------
USER $USER_NAME

# Install Python dependencies
RUN pip3 install --upgrade pip && \
    pip3 install defusedxml rospkg netifaces numpy

# Setup ROS workspace
WORKDIR /workspace/jackal_ws/src
RUN git clone https://github.com/jackal/jackal.git --branch noetic-devel \
    && git clone https://github.com/jackal/jackal_simulator.git --branch melodic-devel \
    && git clone https://github.com/jackal/jackal_desktop.git --branch melodic-devel \
    && git clone https://github.com/utexas-bwi/eband_local_planner.git

# Install ROS dependencies
WORKDIR /workspace/jackal_ws
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
        rosdep init; \
    fi && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src --rosdistro=noetic -y

# Fix the ownership issue
RUN chown -R $USER_NAME:$USER_NAME /workspace/jackal_ws
