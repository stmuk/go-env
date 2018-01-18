#!/usr/bin/env bash

set -e

if [ ! -z "$DEBUG" ]
then
    set -x 
fi

VERSION=$1

if [ -z "$VERSION" ]
then
    echo "Supply version as arg, eg. 1.4, 1.10beta2, tip etc."
    echo "NOTE go1.4 needs to be in place to cross compile later versions"
    exit 1
fi

if [[ $VERSION =~ ^[0-9.]+[beta|rc] ]]; then 

    GOROOT=${HOME}/go${VERSION}
    git clone https://go.googlesource.com/go ${GOROOT}
    cd ${GOROOT} && git checkout go${VERSION}

elif [[ $VERSION =~ ^[0-9.]+$ ]]; then 

    GOROOT=${HOME}/go${VERSION}
    git clone https://go.googlesource.com/go ${GOROOT}
    cd ${GOROOT} && git checkout release-branch.go${VERSION}

elif [[ $VERSION == "tip" ]]; then

    GOROOT=${HOME}/go-tip
    git clone https://go.googlesource.com/go ${GOROOT}
    cd ${GOROOT} 

else
    echo "not recognised try 'tip'"
    exit 1
fi

cd src && ./all.bash

GO=${GOROOT}/bin/go

# this is just for bootstrap
if [[ $VERSION == 1.4 ]]; then
    exit 0
fi

${GO} get -v -v golang.org/x/tools/cmd/...
${GO} get -u -v github.com/golang/dep/cmd/dep

if [[ ! $(uname) =~ "BSD"]]
    ${GO} get -u -v github.com/derekparker/delve/cmd/dlv
fi

SCRIPT=${HOME}/bin/go${VERSION}

cat << EOF > ${SCRIPT}
#!/bin/sh
exec ${GO} "\$@"
EOF
chmod 755 ${SCRIPT}

echo "add ${SCRIPT} to PATH"
