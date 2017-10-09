#!/bin/bash

#bash -xef /home/nadkarni/git/sammba-mri/sammba/projects/MIRCen_sammba-mri_mouse/master_MIRCen_sammba-mri_mouse.bash 2>&1 | tee /home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouse/MIRCen_sammba-mri_mouse/$(date +%Y%m%d_%H%M%S).log

PATH=$PATH:/home/nadkarni/git/sammba-mri/sammba/common
export PATH

PYTHONPATH=$PYTHONPATH:$PATH
export PYTHONPATH

pipeline=pipeline_all.bash #1
projectdir=/home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouse/MIRCen_sammba-mri_mouse
MRIsessionslist=$projectdir/dicomdirs_list.txt #2
analysisdir=$projectdir/analysis20170926
mkdir $analysisdir #3
templatedir=$projectdir/20170925_template
brain=$templatedir/dorrbrainAlQw.nii.gz #4
atlas=$templatedir/dorratlasAlQw.nii.gz #5
mask=$templatedir/dorratlasAlQw.nii.gz #6
head=$templatedir/Qw4_meanhead.nii.gz #7
headweight=$templatedir/aff3_unionmaskdil5.nii.gz #8
basetype=head #9
dofolderoverwrite=no #10
tmpdir=/volatile #11
registerfunctional=no #12
subpipeline=perslice_registration_subpipeline.bash #13
Urad=18.3 #14
brainvol=400 #15
scale=0.1 #16
T1blood=2800 #17
lambda=0.9 #18
multiplier=6000000 #19
T1guess=1600 #20
mccores=16 #21

#					  1			2				 3			  4		 5		6	  7		8			9		  10				 11		 12					 13			  14	15		  16	 17		  18	  19		  20	   21	
pipeline_wrapper.bash $pipeline $MRIsessionslist $analysisdir $brain $atlas $mask $head $headweight $basetype $dofolderoverwrite $tmpdir $registerfunctional $subpipeline $Urad $brainvol $scale $T1blood $lambda $multiplier $T1guess $mccores
