#!/usr/bin/env python3

import argparse
from collections import defaultdict

allowed = {
    'cs': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÝČĎĚŇŘŠŤŮŽ'),
    'de': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß'),
    'en': set('ABCDEFGHIJKLMNOPQRSTUVWXYZ\''),
    'es': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑÜ'),
    'fr': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÉÑËÏŸÜÀÈÙÂÊÎÔÛÇÆ\''),
    'ru': set('АБВДЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'),
    'pt': set('ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑÜÌÀÇÃÊÇÒÔÕÂ'),
}

excluded = set('0123456789!?",.:\/{}()[]¢¦§¨ª®°²½¿│║▀▖▚▜■▪▬˚—ₔ'
               '▲◀◄◎◘☁★☆☋☠☣☤☦☪【￝£–―‚†•′‹⁄€™←↑→↓⇒≄⋅#$%&*+-;<=>'
               '@^_`|~·¸¹ˑГЕ‖₁₌ℂ↔⇇⇑⇗⇚⇞≁≇⌐┃┊└╌═╝▁▇▊▋▒▸◊○☀☂☊☚☜✔✦'
               '➝勓鎘鎮隓ƒʜ×Øø๎:ᚅọ‐‘…⇔✑❝❞№⇘─Є¤©¬­±³¶º»¼¾↩−∙∼≤'
               '►▼●♡♥♦♫�’“″’›∇∑∗√∞≈≡≥━┣╬□▫▶◆◙☺☼♀♂♠♣♪✖❤哻嫳鎙鏮'
               '隳:1₡↳∇∑₴”℗⇄⇆∂∅⌘✓✭‡‣※₹℃↵∈∧∨≠⊕⊖〉Ⓒ▄█░▓'
               '¥▾◇◦☎☛☞♔♛♬✧✿❑➜、。」』】・），：；｜～￥'
               '‑‰₂₪▮▷☻♐✏✱➢')

def clean(n, lang, fn_i, fn_o):
    letter_set = defaultdict(int)
    letter_set_ex = defaultdict(int)

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

                    if wordform not in ['<s>', '</s>']:
                        if set(wordform) - allowed[lang]:
                            print(wordform)
                            for c in set(wordform) - allowed[lang] - excluded:
                                letter_set_ex[c] += 1
                            continue

                        for c in wordform:
                            letter_set[c] += 1

                    if n_words > n:
                        break

                    n_words += 1

                    o.write('{w}\n'.format(w=wordform))

                except UnicodeDecodeError:
                    print('UnicodeDecodeError')
                    pass

    return letter_set, letter_set_ex


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

    letter_set, letter_set_ex = clean(args.n, args.lang, args.input, args.output)

    print('The letter set:')
    for k, v in sorted(letter_set.items()):
        print('{l}:{c}'.format(l=k, c=v), end=' ')
    print('')
    print('')

    print('The letter set of exluded word forms:')
    for k, v in sorted(letter_set_ex.items()):
        print('{l}:{c}'.format(l=k, c=v), end=' ')
    print('')

    print('')
    print('')
