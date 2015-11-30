#!/usr/bin/env python3

import argparse

allowed = {
    'en': set('ABCDEFGHIJKLMNOPQRSTUVWXYZ\''),
    'cs': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÝČĎĚŇŘŠŤŮŽ'),
}


def clean(n, lang, fn_i, fn_o):
    letter_set = set()

    n_words = 0
    with open(fn_i, 'rt', encoding='utf8') as i:
        with open(fn_o, 'wt', encoding='utf8') as o:
            while True:
                try:
                    l = i.readline()
                    if not l:
                        break

                    l = l.strip().split()

                    if len(l) != 2:
                        continue

                    wordform = l[0]
                    count = int(l[1])

                    if len(wordform) > 15:
                        continue

                    if count < 5:
                        continue

                    if set(wordform) - allowed[lang]:
                        continue

                    if n_words > n:
                        break

                    n_words += 1

                    letter_set.update(set(wordform))
                    o.write('{w} {c}'.format(w=wordform, c=count))
                    o.write('\n')

                except UnicodeDecodeError:
                    print('UnicodeDecodeError')
                    pass

    return letter_set


if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="""
    Filter the dictionary items so that thy are suitable for an ASR system.

    """)

    parser.add_argument('-n', action="store", type=int, help='a number of word in the output dictionary')
    parser.add_argument('-l', '--lang', action="store", help='the language the output dictionary (en, cs, ...)')
    parser.add_argument('input', action="store", help='a file with input dictionary')
    parser.add_argument('output', action="store", help='a file for the output dictionary')

    args = parser.parse_args()

    letter_set = clean(args.n, args.lang, args.input, args.output)

    print('The letter set:')
    print(' '.join(sorted(letter_set)))

    print('')
    print('')
