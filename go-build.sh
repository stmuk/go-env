#!/usr/bin/env bash

set -x 

VERSION=$1

if [ -z "$VERSION" ]
then
    echo "supply version as arg, eg. 1.4, tip"
    exit 1
fi

if [[ $VERSION =~ ^[0-9.]+$ ]]; then 

    GOROOT=${HOME}/go${VERSION}
    git clone https://go.googlesource.com/go ${GOROOT}
    cd ${GOROOT} && git checkout release-branch.go${VERSION}

elif [[ $VERSION == "tip" ]]; then

    GOROOT=${HOME}/go-tip
    git clone https://go.googlesource.com/go ${GOROOT}
    cd ${GOROOT} 

else
    echo "not recognised try 'tip'"
fi

cd src && ./all.bash

GO=${GOROOT}/bin/go

# this is just for bootstrap
if [[ $VERSION == 1.4 ]]; then
    exit 0
fi

${GO} get -v -v golang.org/x/tools/cmd/...
${GO} get -u -v github.com/golang/dep/cmd/dep
${GO} get -u -v github.com/derekparker/delve/cmd/dlv # broken FreeBSD

SCRIPT=${HOME}/bin/go${VERSION}

echo "add ${SCRIPT} to PATH"
cat << EOF > ${SCRIPT}
#!/bin/sh
exec ${GO} "\$@"
EOF
chmod 755 ${SCRIPT}
