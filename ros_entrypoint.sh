#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/noetic/setup.bash"
source "/cartographer_ws/install_isolated/setup.bash"
exec "$@"
