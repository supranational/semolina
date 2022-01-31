#!/bin/sh

HERE=`dirname $0`
cd "${HERE}"

PERL=${PERL:-perl}

for pl in asm/*-x86_64.pl; do
    s=`basename $pl .pl`.asm
    (set -x; ${PERL} $pl masm > win64/$s)
    s=`basename $pl .pl`.s
    (set -x; ${PERL} $pl elf > elf/$s)
    (set -x; ${PERL} $pl mingw64 > coff/$s)
    (set -x; ${PERL} $pl macosx > mach-o/$s)
done

for pl in asm/*-armv8.pl; do
    s=`basename $pl .pl`.asm
    (set -x; ${PERL} $pl win64 > win64/$s)
    s=`basename $pl .pl`.S
    (set -x; ${PERL} $pl linux64 > elf/$s)
    (set -x; ${PERL} $pl coff64 > coff/$s)
    (set -x; ${PERL} $pl ios64 > mach-o/$s)
done
