# Opioid Trends in Indiana

Scripts for compiling, validating, and visualizing the Indiana Addictions Data Commons (IADC) Data.

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

## Credits

Developed as a collaboration between the [Cyberinfrastructure for Network Science Center at Indiana University](http://cns.iu.edu/) and the [Regenstrief Institute](https://www.regenstrief.org/) as part of Indiana University's [Addictions Grand Challenge](https://addictions.iu.edu/responding-to-crisis/grand-challenge.html).
