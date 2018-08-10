#!/usr/bin/env python3

import sys
import re

print("WARNING: this script does not work yet because it requires the github releases to exist already...")

tag = sys.argv[0]

# upload_github is from https://github.com/qutebrowser/qutebrowser/blob/v1.4.1/scripts/dev/build_release.py#L342-L367
def upload_github(tag, filename, mimetype, description):
    import github3
    print("=== Uploading to github... ===")
    token = input('Enter the github token: ')
    gh = github3.login(token=token)
    repo = gh.repository('herbstluftwm', 'herbstluftwm')

    # release = None  # to satisfy pylint
    for release in repo.releases():
        if release.tag_name == tag:
            break
    else:
        raise Exception("No release found for {!r}!".format(tag))

    with open(filename, 'rb') as f:
        basename = os.path.basename(filename)
        asset = release.upload_asset(mimetype, basename, f)
    asset.edit(basename, description)

# an ad-hoch asciidoc parser
def parse_sections(asciidoc_txt):
    header_exp = re.compile('^Release (.*) on (.*)$')
    underline_exp = re.compile('^-[-]*$')
    body = []
    sections = []
    lastline = None
    for line in asciidoc_txt.splitlines():
        if underline_exp.match(line):
            match = header_exp.match(lastline)
            if match:
                body = []
                sections.append((match.group(1), match.group(2), body))
            lastline = None
        else:
            if not lastline is None:
                body.append(lastline)
            lastline = line
        # print(">>> " + line)
    body.append(lastline)
    return sections

news_file = '../herbstluftwm/NEWS'
with open(news_file, 'r') as f:
    sections = parse_sections(f.read())

for vers,date,body in sections:
    if vers == '0.7.1':
        # print('\n'.join(body))
        upload_github(vers, \
            'tarballs/herbstluftwm-0.7.1.tar.gz',
            'application/x-gzip',
            body)

