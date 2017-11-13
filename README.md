## Static Executables

Compile static executables in an alpine Docker container with musl.

Prerequisites:

- [GNU Make](https://www.gnu.org/software/make/).
- [Docker](https://www.docker.com/), installed with regular user access.
- If behind a proxy, run [CNTLM](http://cntlm.sourceforge.net/) on the host at `0.0.0.0:3128`.

List of products:

    the_silver_searcher-2.1.0
    bash-4.4.12
    rsync-3.1.2
    socat-1.7.3.2
    tmux-2.6

Use:

    # build all
    #   create docker container to use as builder
    #   download sources in src/
    #   build products in output/
    make
    cp output/bin/* /your/destination/path
    
    # cleanup
    #   remove docker container
    #   remove sources
    #   remove products
    make cleanall

Inspired by:
https://github.com/andrew-d/static-binaries
