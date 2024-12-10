#!/usr/bin/python
# -*- coding:UTF-8 -*-
import os
import sys
import re
#import pdb

default_ignoreds=[
        './dep/',
        './csserver/',
        './tools/',
        './protocol/star_aisvr.pack.c',
        './protocol/star_comm.pack.c',
        './protocol/star_cs.pack.c',
        './protocol/star_db.pack.c',
        './protocol/star_def.libpack.c',
        './protocol/star_def.pack.c',
        './protocol/star_macro.pack.c',
        './protocol/star_protocol.c',
        './protocol/star_shm2db.pack.c',
        './protocol/star_ss.pack.c',
        './protocol/star_sync.pack.c',
        './protocol/keywords.h',
        './protocol/star_aisvr.h',
        './protocol/star_aisvr.pack.h',
        './protocol/star_comm.h',
        './protocol/star_comm.pack.h',
        './protocol/star_cs.h',
        './protocol/star_cs.pack.h',
        './protocol/star_db.h',
        './protocol/star_db.pack.h',
        './protocol/star_def.h',
        './protocol/star_def.libpack.h',
        './protocol/star_def.pack.h',
        './protocol/star_macro.h',
        './protocol/star_macro.pack.h',
        './protocol/star_res.h',
        './protocol/star_shm2db.h',
        './protocol/star_shm2db.pack.h',
        './protocol/star_ss.h',
        './protocol/star_ss.pack.h',
        './protocol/star_stat_report.h',
        './protocol/star_sync.h',
        './protocol/star_sync.pack.h',
        './protocol/star_userlog_define.h',
        './gameidipsvr/lgame_idip_protocol.h',
        './funcsvr/webproxy/esports_data.pb.h',
        './funcsvr/framework/star_ml.pb.h',
        './funcsvr/webproxy/esports_data.pb.cc',
        './funcsvr/framework/star_ml.pb.cc'
        ]

default_pgame_ignoreds=[
        'bin/luascript/tables_repo'
        ]

def GenerateTag2CtrlpTag(filein:str,fileout:str,ignored_prefix_lists=default_ignoreds):
    if os.path.exists(filein) is False:
        sys.exit(0)

    if os.path.exists(fileout):
        os.remove(fileout)

    tag_dict={}
    with open(fileout,'w',encoding='utf8') as fw:
        with open(filein,'r',encoding='utf8') as fr:
            for line in fr.readlines():
                if line[0:6]=='!_TAG_':
                    fw.write(line)
                    continue
                segment = line.split('\t')

                if len(segment) < 2:
                    # 格式不对，忽略
                    continue

                if len(segment[0]) < 5:
                    #tag名称长度太短，直接忽略
                    continue

                bIgnored=False
                for prefix in ignored_prefix_lists:
                    if segment[1].find(prefix) == 0:
                        bIgnored=True
                        break

                if bIgnored is True:
                    continue

                if tag_dict.get(segment[0],0) == 1:
                    continue
                fw.write(line)

def GenerateTagStat(filein:str,fileout:str):
    if os.path.exists(filein) is False:
        sys.exit(0)

    filelist_dict={}
    with open(fileout,'w',encoding='utf8') as fw:
        with open(filein,'r',encoding='utf8') as fr:
            for line in fr.readlines():
                if line[0:6]=='!_TAG_':
                    fw.write(line)
                    continue
                segment = line.split('\t')

                if len(segment) < 2:
                    # 格式不对，忽略
                    continue
                if segment[1] not in filelist_dict.keys():
                    filelist_dict[segment[1]]=1
                else:
                    filelist_dict[segment[1]]+=1
                fw.write(line)

    filelists_sorted=[]
    for k,v in filelist_dict.items():
        filelists_sorted.append((k,v))

    filelists_sorted.sort(key=lambda x:x[1],reverse=True)
    with open(fileout,'w',encoding='utf8') as fw:
        for item in filelists_sorted:
            fw.write('{},\t{}\n'.format(item[1],item[0]))

def PGameGenerateTag2CtrlpTag(filein:str,fileout:str):
    GenerateTag2CtrlpTag(filein,fileout,default_pgame_ignoreds)


#GenerateTag2CtrlpTag('G:\\CodeBase.p4\\trunkmain.Server_proj\\lgamesvrc.tags',
#        'G:\\CodeBase.p4\\trunkmain.Server_proj\\lgamesvrc.ctrltags')
#
#GenerateTagStat('G:\\CodeBase.p4\\trunkmain.Server_proj\\lgamesvrc.ctrltags',
#        'G:\\CodeBase.p4\\trunkmain.Server_proj\\lgamesvrc.ctrltagsstat')
