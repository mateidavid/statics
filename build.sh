#!/bin/bash
set -eEux
trap 'echo "exit code $?: LINENO=$LINENO" >&2' ERR

get_source_dir () {
    tar -tf "$1" | sed 's,/.*$,,' | sort | uniq
}

build () {
    eval "$1_defs"
    echo "building: $name-$version"
    if [ -f "/output/$product" ]; then
        echo "already built: /output/$product"
        return 0
    fi
    src_file=$(basename "$url")
    [ -f "$src_file" ] || curl -LOv "$url"
    dir=$(get_source_dir "$src_file")
    [ -d "$dir" ] || tar -xf "$src_file"
    cd "$dir"
    commands
    cd -
}

bash_defs () {
    name=bash
    version=4.4.12
    url=https://mirrors.kernel.org/gnu/${name}/${name}-${version}.tar.gz
    product=bin/bash
    commands () {
        ./configure --prefix=/output --enable-static-link --without-bash-malloc
        make -j4
        make install
    }
}

libevent_defs () {
    name=libevent
    version=2.1.8
    url=https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
    product=lib/libevent.a
    commands () {
        ./configure --prefix=/output --disable-shared
        make -j4
        make install
    }
}

ncurses_defs () {
    name=ncurses
    version=6.0
    url=https://mirrors.kernel.org/gnu/${name}/${name}-${version}.tar.gz
    product=lib/libncurses.a
    commands () {
        ./configure --prefix=/output --without-shared --with-default-terminfo-dir=/usr/share/terminfo --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo"
        make -j4
        make install
    }
}

tmux_defs () {
    name=tmux
    version=2.6
    url=https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
    product=bin/tmux
    commands () {
        ./configure --prefix=/output --enable-static LIBEVENT_CFLAGS="-I/output/include" LIBEVENT_LIBS="-L/output/lib -levent" LIBNCURSES_CFLAGS="-I/output/include/ncurses" LIBNCURSES_LIBS="-L/output/lib -lncurses"
        make -j4
        make install
    }
}

readline_defs () {
    name=readline
    version=7.0
    url=https://mirrors.kernel.org/gnu/${name}/${name}-${version}.tar.gz
    product=lib/libreadline.a
    commands () {
        ./configure --prefix=/output --disable-shared
        make -j4
        make install
    }
}

openssl_defs () {
    # ref: https://github.com/andrew-d/static-binaries/blob/master/socat/build.sh
    name=openssl
    version=1.1.0f
    url=https://www.openssl.org/source/${name}-${version}.tar.gz
    product=lib/libcrypto.a
    commands () {
        ./config --prefix=/output no-shared no-async
        make -j4
        make install_sw
    }
}

socat_defs () {
    # ref: https://github.com/andrew-d/static-binaries/blob/master/socat/build.sh
    name=socat
    version=1.7.3.2
    url=http://www.dest-unreach.org/socat/download/socat-${version}.tar.gz
    product=bin/socat
    commands () {
        ./configure --prefix=/output CC="/usr/bin/gcc -static" CPPFLAGS="-I/output -DNETDB_INTERNAL=-1" LDFLAGS="-L/output"
        make -j4
        make install
    }
}

build bash
build libevent
build ncurses
build tmux
build readline
build openssl
build socat
