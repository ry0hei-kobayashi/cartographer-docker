FROM osrf/ros:noetic-desktop-full
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

#-----------------------------
# Environment Variables
#-----------------------------
ENV LC_ALL=C.UTF-8
ENV export LANG=C.UTF-8
# no need input key
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-c"]


#install common pkg
#-----------------------------
RUN apt-get -y update
RUN apt-get -y install git ssh python3-pip wget net-tools vim curl make build-essential lsb-release cmake

#-----------------------------
#install tmc-ros pkg
#-----------------------------

#RUN echo "deb [arch=amd64] https://hsr-user:jD3k4G2e@packages.hsr.io/ros/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/tmc.list
#RUN echo "deb [arch=amd64] https://hsr-user:jD3k4G2e@packages.hsr.io/tmc/ubuntu `lsb_release -cs` multiverse main" >> /etc/apt/sources.list.d/tmc.list
#RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list
#
#RUN wget https://hsr-user:jD3k4G2e@packages.hsr.io/tmc.key -O - | apt-key add -
#RUN wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -O - | apt-key add -
#RUN wget https://packages.osrfoundation.org/gazebo.key -O - |  apt-key add -
#
#RUN mkdir -p /etc/apt/auth.conf.d
#RUN echo -e "machine packages.hsr.io\nlogin hsr-user\npassword jD3k4G2e" >/etc/apt/auth.conf.d/auth.conf
#RUN apt-get update -y
#RUN apt-get install -y ros-noetic-tmc-desktop-full

#source /opt/ros/noetic/setup.bash
#setup tool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_toyota_hsr/master/cartographer_toyota_hsr.rosinstall
RUN mkdir -p /cartographer_ws/src
WORKDIR /cartographer_ws

RUN apt-get install -y python3-wstool python3-rosdep ninja-build stow
RUN pip install jinja2==3.0.3
RUN cd /cartographer_ws && . /opt/ros/noetic/setup.bash && \
    wstool init src && \
    wstool update -t src && \
    wstool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_toyota_hsr/master/cartographer_toyota_hsr.rosinstall && \
    wstool update -t src


RUN cd /cartographer_ws/src/cartographer/scripts && \
    ./install_abseil.sh && \
    sleep 1 && \
    cd /usr/local/stow && \
    stow absl

    # Install deb dependencies.
RUN cd /cartographer_ws/src/cartographer/ && \
    sed -i '/absl/d' package.xml && \
    cd /cartographer_ws && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r --rosdistro=noetic -y 

RUN cd /cartographer_ws && . /opt/ros/noetic/setup.bash && \
    catkin_make_isolated --install --use-ninja

RUN echo "source /cartographer_ws/install_isolated/setup.bash" >> ~/.bashrc && \
    source install_isolated/setup.bash && \
    source ~/.bashrc 


COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]

WORKDIR /cartographer_ws
