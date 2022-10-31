import sys
import os
import re
import pdb


def P4Changes2GoogleDoc():
    fin='./.myp4.out.changes'
    fout='./.myp4.out.googlechanges'

    if not os.path.exists(fin):
        sys.exit(0)

    if os.path.exists(fout):
        os.remove(fout)

    with open(fin,'r',encoding='utf8') as fr:
        in_lines=fr.readlines()
        strCon='\n'.join(in_lines)
        fr.close()

    myre=re.compile(r'''Change\s*(?P<changenum>\d*)
                        \s+on\s+(?P<date>\d+\/\d+\/\d+\s*\d+:\d+:\d+)
                        \s*by\s+(?P<owner>\w+)@
                        (?P<client>[\w\.]*)$
                        .*?
                        ShortSummary:(?P<summary>.*?)$
                        .*?
                        \[reviewers:(?P<reviewer>[a-z,]+?)\].*?$
                        .*?
                        \[tapd:(?P<tapd>[\w\:/\.]+?)\]
            ''',re.VERBOSE|re.MULTILINE|re.IGNORECASE|re.UNICODE|re.DOTALL)

    str_title=''
    str_lines=[]
    for ret in myre.finditer(strCon):
        mydict=ret.groupdict()
        strline=''
        str_title=''
        for key,value in mydict.items():
            str_title+=key+'\t'
            strline+=value+'\t'
        str_title+="\n"
        strline+="\n"
        str_lines.append(strline)

    str_lines.insert(0,str_title)

    with open(fout,'w',encoding='utf8') as fw:
        fw.writelines(str_lines)

