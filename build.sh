docker build -t harbormaster .
docker run -v ~/harbormaster-output/:/output/ -v ~/harbormaster-build/:/build/ -it --privileged --rm --entrypoint=/bin/bash harbormaster
