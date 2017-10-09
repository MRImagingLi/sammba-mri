#!/bin/bash

#bash -xef /home/nadkarni/git/sammba-mri/sammba/projects/XNAT_CSD_MRI_MOUSE_testretest/master_XNAT_CSD_MRI_MOUSE_testretest.bash 2>&1 | tee /home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouse/XNAT_CSD_MRI_MOUSE_testretest/$(date +%Y%m%d_%H%M%S).log

PATH=$PATH:/home/nadkarni/git/sammba-mri/sammba/common
PATH=$PATH:/home/nadkarni/git/sammba-mri/sammba/projects/XNAT_CSD_MRI_MOUSE_testretest
export PATH

PYTHONPATH=$PYTHONPATH:$PATH
export PYTHONPATH

pipeline=pipeline_XNAT_CSD_MRI_MOUSE_testretest.bash #1
projectdir=/home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouse/XNAT_CSD_MRI_MOUSE_testretest
MRIsessionslist1=$projectdir/baselinesessions.txt #2
MRIsessionslist2=$projectdir/postsessions.txt #2
analysisdir=$projectdir/analysis20170926
analysisdir1=$analysisdir/baseline #3
analysisdir2=$analysisdir/post #3
mkdir $analysisdir $analysisdir1 $analysisdir2
templatedir=$projectdir/20170925_goodposttemplate
brain=$templatedir/dorrbrainAlQw.nii.gz #4
atlas=$templatedir/dorratlasAlQw.nii.gz #5
mask=$templatedir/dorratlasAlQw.nii.gz #6
head=$templatedir/Qw4_meanhead.nii.gz #7
headweight=$templatedir/aff3_unionmaskdil4.nii.gz #8
basetype=head #9
dofolderoverwrite=no #10
tmpdir=/volatile #11
registerfunctional=yes #12
subpipeline=perslice_registration_subpipeline.bash #13
Urad=18.3 #14
brainvol=400 #15
scale=0.1 #16

cd $analysisdir

#                     1         2                 3             4      5      6     7     8           9         10                 11      12                  13           14    15        16     17       18      19          20       21
pipeline_wrapper.bash $pipeline $MRIsessionslist1 $analysisdir1 $brain $atlas $mask $head $headweight $basetype $dofolderoverwrite $tmpdir $registerfunctional $subpipeline $Urad $brainvol $scale $T1blood $lambda $multiplier $T1guess $mccores
pipeline_wrapper.bash $pipeline $MRIsessionslist2 $analysisdir2 $brain $atlas $mask $head $headweight $basetype $dofolderoverwrite $tmpdir $registerfunctional $subpipeline $Urad $brainvol $scale $T1blood $lambda $multiplier $T1guess $mccores
