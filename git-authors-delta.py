#!/usr/bin/env python3

import os
import sys
import subprocess


def dict_minus_inplace(bigger, smaller):
    for name, count in smaller.items():
        assert name in bigger
        bigger[name] -= count


def gitlog2dict(gitlog, aliases={}):
    author2count = {}
    for l in gitlog.decode().splitlines():
        if l in aliases:
            l = aliases[l]
        if l not in author2count:
            author2count[l] = 0
        author2count[l] += 1
    return author2count


def main():
    """
    Print commit statistics between two github revisions, e.g.:

    github-releases.py v0.9.0 v0.9.1

    """
    old = sys.argv[1]
    new = sys.argv[2]

    cmd = ['git', 'log', '--oneline', '--format=%an']
    oldlog = subprocess.run(cmd + [old], stdout=subprocess.PIPE, check=True)
    newlog = subprocess.run(cmd + [new], stdout=subprocess.PIPE, check=True)
    aliases = {
        'dnnr': 'Daniel Danner',
        'ypnos': 'Johannes Jordan',
    }
    olddict = gitlog2dict(oldlog.stdout, aliases=aliases)
    newdict = gitlog2dict(newlog.stdout, aliases=aliases)
    dict_minus_inplace(newdict, olddict)
    authorlist = []
    for name, count in newdict.items():
        if count == 0:
            continue
        authorlist.append((count, name))
    total = 0
    for count, name in sorted(authorlist):
        print("{}: {} commits".format(name, count))
        total += count
    print("total number of commits: {}".format(total))

main()
