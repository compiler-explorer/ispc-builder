# ISPC Compiler build scripts

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build Intel's ISPC compiler.

## To Test

* `sudo docker build -t ispcbuilder .`
* `sudo docker run ispcbuilder ./build.sh trunk`

### Alternative to run (for better debugging)

* `sudo docker run -t -i ispcbuilder bash`
* `./build.sh trunk`
