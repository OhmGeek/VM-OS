#!/bin/bash
# Enter our fakeroot build system for building the image.

docker run -v $(pwd):/build -it --rm debian /bin/bash