#!/usr/bin/env python3

import hashlib
import random
import subprocess as sp
import sys


def cryptol_md5(s):
    md5_file = 'md5.cry'
    cmd = f'md5 (join "{s}")'

    cp = sp.run([
        'cryptol',
        '-e',
        '-c', f':l {md5_file}',
        '-c', ':set ascii=on',
        '-c', ':set warnDefaulting=off',
        '-c', f'{cmd}'],
        stdout=sp.PIPE)
    res = []
    for line in cp.stdout.split(b'\n'):
        if not line.startswith(b'Loading module'):
            res.append(line)
    return b''.join(res).decode(encoding='ascii')


def python_md5(s):
    hexdigest = hashlib.md5(bytes(s, encoding='ascii')).hexdigest()
    return '0x{}'.format(hexdigest)


CHARS = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ'
         'abcdefghijklmnopqrstuvwxyz'
         '0123456789')


def gen_input(max_len, chars):
    res = []
    i = 0
    while i < max_len:
        res += random.choice(chars)
        i += 1
    return ''.join(res)


def main(max_len):
    i = 0
    failed = []
    failed_cnt = 0
    passed_cnt = 0
    while i < max_len:
        s = gen_input(i, CHARS)
        print(f'count: {i + 1}/{max_len}, input: {s}')
        p = python_md5(s)
        c = cryptol_md5(s)
        if p != c:
            print(f'FAIL: python: {p}, cryptol: {c}')
            failed.append((s, p, c))
            failed_cnt += 1
        else:
            print(f'PASS: python: {p}, cryptol: {c}')
            passed_cnt += 1
        i += 1

    print('\nPASSED: {}, FAILED: {}'.format(passed_cnt, failed_cnt))
    for f in failed:
        print(f)


if __name__ == '__main__':
    max_len = int(sys.argv[1])
    main(max_len)
