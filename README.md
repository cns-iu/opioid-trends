# Indiana Addictions Data Commons Visualizations

## Opioid Trends in Indiana

Scripts for compiling, validating, and visualizing the IADC Data.

## Change Log

See [CHANGELOG](docs/CHANGELOG.md)

## Base Requirements

* bash
* Python 3+
* Java 1.8+
* Node JS 8+
* sqlite3
* sqlcipher
* GraphViz (dot)
* MkDocs

## Singularity

A Docker container is provided that installs all the dependencies needed for building the AGC1 dataset. You can install the container using this command: `singularity build container.sif docker://cnsiu/a2agc-dataset`. This will create a `container.sif` file that can be invoked on command line: `$ ./container.sif` which will bring you into the container with all dependencies installed and at a shell prompt.
