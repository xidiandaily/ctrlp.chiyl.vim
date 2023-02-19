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
                        \s*by\s+(?P<owner>[^@]+)@(?P<client>.*?)$
                        (?P<summary>.*?)
                        \[reviewers:(?P<reviewer>[^\]]*?)\].*?$
                        .*?
                        \[tapd:(?P<tapd>[^\]]+?)\]
            ''',re.VERBOSE|re.MULTILINE|re.IGNORECASE|re.UNICODE|re.DOTALL)

#    mystr='''
#Change 1889853 on 2022/09/13 04:52:27 by LGame_Builder@sync_protocol_client_svr1663015635.51_41
#
#	auto rsync from sync_protoco.py
#	Code reviewLink:
#	[reviewers:]
#	[tapd:http://tapd.oa.com/LSGame/prong/stories/view/1010147831860890191]
#	[MergeFromTrunk:false]
#
#
#    '''
#    ret=myre.findall(mystr)
#    pdb.set_trace()

    str_title=''
    str_lines=[]
    for ret in myre.finditer(strCon):
        mydict=ret.groupdict()
        strline=''
        str_title=''
        for key,value in mydict.items():
            str_title+=key+'\t'
            strline+=value.replace('\n','').replace('\t','').replace('ShortSummary:','').replace('	Code reviewLink:','').replace('https://cr.lgame.qq.com/reviews/',' link:')+'\t'
        str_title+="\n"
        strline+="\n"
        str_lines.append(strline)

    str_lines.insert(0,str_title)

    with open(fout,'w',encoding='utf8') as fw:
        fw.writelines(str_lines)

#P4Changes2GoogleDoc()
