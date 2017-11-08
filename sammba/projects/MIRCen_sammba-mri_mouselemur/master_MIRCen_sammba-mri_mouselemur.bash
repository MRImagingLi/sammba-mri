#!/bin/bash

#bash -xf /home/nadkarni/git/sammba-mri/sammba/projects/MIRCen_sammba-mri_mouselemur/master_MIRCen_sammba-mri_mouselemur.bash 2>&1 | tee /home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouselemur/MIRCen_sammba-mri_mouselemur/$(date +%Y%m%d_%H%M%S).log

export AFNI_DECONFLICT=OVERWRITE

PATH=$PATH:/home/nadkarni/git/sammba-mri/sammba/common
export PATH

PYTHONPATH=$PYTHONPATH:$PATH
export PYTHONPATH

projectdir=/home/Promane/2014-ROMANE/5_Experimental-Plan-Experiments-Results/mouselemur/MIRCen_sammba-mri_mouselemur
savedir=$projectdir/analysis20171017
mkdir $savedir

dicomdirlist=$projectdir/dicomdirs.txt
nlines=$(wc -l $dicomdirlist | awk '{print $1}')

for ((a=1; a<=$nlines; a++)); do
	dicomdir=$(head -n$a < $dicomdirlist | tail -n1)
	NIfTIdir=$savedir/$(basename $dicomdir)
	mkdir $NIfTIdir
	python -m PVEnDCMtoNIfTI.py /usr/bin/dcmdump $dicomdir $NIfTIdir yes
	IDsequencetypes.bash $NIfTIdir
done

mv $savedir/20170425_115121_208CBF_1_1/anat_n0.nii.gz $savedir/20170425_115121_208CBF_1_1/badanat_n1.nii.gz
mv $savedir/20170425_115121_208CBF_1_1/208CBF__20170425__132441__MSME_MIRCen_RatBrain_atlas__fixedSIAP__bf11.nii.gz $savedir/20170425_115121_208CBF_1_1/anat_n0.nii.gz
mv $savedir/20170425_164314_289BB_1_1/anat_n0.nii.gz $savedir/20170425_164314_289BB_1_1/badanat_n2.nii.gz
mv $savedir/20170425_164314_289BB_1_1/289BB__20170425__171045__MSME_200um__fixedSIAP__bf6.nii.gz $savedir/20170425_164314_289BB_1_1/anat_n0.nii.gz
mv $savedir/20170425_192223_310C_1_1/anat_n0.nii.gz $savedir/20170425_192223_310C_1_1/badanat_n1.nii.gz
mv $savedir/20170425_192223_310C_1_1/310C__20170425__194739__MSME_200um__fixedSIAP__bf6.nii.gz $savedir/20170425_192223_310C_1_1/anat_n0.nii.gz

for ((a=1; a<=$nlines; a++)); do
	dicomdir=$(head -n$a < $dicomdirlist | tail -n1)
	NIfTIdir=$savedir/$(basename $dicomdir)
	3dZeropad -RL 160 -AP 160 -IS 100 -prefix $NIfTIdir/anat.nii.gz $NIfTIdir/anat_n0.nii.gz
done

#create raw data video and mean
3dTcat -prefix $savedir/raw_video.nii.gz $(find $savedir -name 'anat.nii.gz')
3dTstat -prefix $savedir/raw_mean.nii.gz $savedir/raw_video.nii.gz

conv=0.01
twoblur=2
brainvol=1600
#-rbt values might be improveable
Urad=18.3
b=70
t=80

bash MRIT2_extrcen.bash $savedir $brainvol $Urad $b $t
bash MRIT3_shr.bash $savedir $savedir/UnBmBeCC_mean.nii.gz 1 $conv $twoblur
bash MRIT3_shr.bash $savedir $savedir/shr1_mean.nii.gz 2 $conv $twoblur
bash MRIT4_aff.bash $savedir $savedir/shr2_meanhead.nii.gz 2 3 $conv $twoblur $savedir/shr2_count.nii.gz

3dmask_tool -frac 0.5 -inputs $savedir/aff3_video.nii.gz -prefix $savedir/aff3_frac05mask.nii.gz
3dcalc -a $savedir/aff3_meanhead.nii.gz -expr 'step(1.5-(x-5.9)*(x-5.9)-(y-5.7)*(y-5.7)-(z+2.3)*(z+2.3))' -prefix $savedir/leftcolliculus.nii.gz
3dcalc -a $savedir/aff3_meanhead.nii.gz -expr 'step(1.5-(x+5.5)*(x+5.5)-(y-5.7)*(y-5.7)-(z+2.5)*(z+2.5))' -prefix $savedir/rightcolliculus.nii.gz
3dmask_tool -union -inputs $savedir/aff3_frac05mask.nii.gz $savedir/rightcolliculus.nii.gz $savedir/leftcolliculus.nii.gz -prefix $savedir/aff3_unionmask.nii.gz
3dmask_tool -dilate_inputs 3 -inputs $savedir/aff3_unionmask.nii.gz -prefix $savedir/aff3_unionmaskdil3.nii.gz
weight=$savedir/aff3_unionmaskdil3.nii.gz

bash MRIT5_Qw.bash $savedir $savedir/aff3_meanhead.nii.gz $weight UnCC.nii.gz UnBmBeCCAl2UnCCAl3.aff12.1D 0 4 1
bash MRIT5_Qw.bash $savedir $savedir/Qw1_meanhead.nii.gz $weight UnCC.nii.gz UnCCQw1_WARP.nii.gz 5 7 2
bash MRIT6_Qw.bash $savedir $savedir/Qw2_meanhead.nii.gz $weight UnCC.nii.gz UnCCQw2_WARP.nii.gz 8 13 3
bash MRIT6_Qw.bash $savedir $savedir/Qw3_meanhead.nii.gz $weight UnCC.nii.gz UnCCQw3_WARP.nii.gz 10 7 4

MLAdir=/home/Pmamobipet/Tvx-Manips-MD_/MD_1701-Microcebe-Creation-Atlas/essai_JLP
3dAllineate -source $MLAdir/Apr2Feb.nii.gz -base $savedir/aff3_mean.nii.gz -prefix $savedir/MLAbrainAl.nii.gz -1Dmatrix_save $savedir/MLAbrainAl.aff12.1D
3dQwarp -base $savedir/Qw4_meanhead.nii.gz -source $savedir/MLAbrainAl.nii.gz -prefix $savedir/MLAbrainAlQw.nii.gz -noneg -blur 0 -nmi
3dNwarpCat -prefix $savedir/MLAbrainAlQwcat_WARP.nii.gz $savedir/MLAbrainAlQw_WARP.nii.gz $savedir/MLAbrainAl.aff12.1D
3dNwarpApply -nwarp $savedir/MLAbrainAlQwcat_WARP.nii.gz -source $MLAdir/Lemur-Atlas-Apr2Feb-vca1-label.nii.gz -master $savedir/Qw4_meanhead.nii.gz -ainterp NN -prefix $savedir/MLAatlasAlQw.nii.gz
cp $MLAdir/Lemur-Atlas-Apr2Feb-cortexR-label.nii $savedir
3dNwarpApply -nwarp $savedir/MLAbrainAlQwcat_WARP.nii.gz -iwarp -source $savedir/Qw4_meanhead.nii.gz -master $MLAdir/Apr2Feb.nii.gz -prefix $savedir/Qw4_meanhead_Na.nii.gz
3dNwarpApply -nwarp $savedir/MLAbrainAlQwcat_WARP.nii.gz -iwarp -source $savedir/aff3_unionmaskdil3.nii.gz -master $MLAdir/Apr2Feb.nii.gz -prefix $savedir/aff3_unionmaskdil3_Na.nii.gz
3dresample -dxyz 0.2 0.2 0.2 -rmode Cu -prefix $savedir/Qw4_meanhead_Na_200.nii.gz -input $savedir/Qw4_meanhead_Na.nii.gz
3dresample -dxyz 0.3 0.3 0.3 -rmode Cu -prefix $savedir/Qw4_meanhead_Na_300.nii.gz -input $savedir/Qw4_meanhead_Na.nii.gz
3dresample -dxyz 0.2 0.2 0.2 -rmode Cu -prefix $savedir/aff3_unionmaskdil3_Na_200.nii.gz -input $savedir/aff3_unionmaskdil3_Na.nii.gz
3dresample -dxyz 0.2 0.2 0.2 -rmode NN -prefix $savedir/Lemur-Atlas-Apr2Feb-cortexR-label_200.nii.gz -input $savedir/Lemur-Atlas-Apr2Feb-cortexR-label.nii
3dresample -dxyz 0.3 0.3 0.3 -rmode NN -prefix $savedir/Lemur-Atlas-Apr2Feb-cortexR-label_300.nii.gz -input $savedir/Lemur-Atlas-Apr2Feb-cortexR-label.nii
3dcalc -a $savedir/Qw4_meanhead.nii.gz -b $savedir/aff3_frac05mask.nii.gz -expr 'a*ispositive(b)' -prefix $savedir/Qw4_meanhead_brain.nii.gz
3dNwarpApply -nwarp $savedir/MLAbrainAlQwcat_WARP.nii.gz -iwarp -source $savedir/Qw4_meanhead_brain.nii.gz -master $MLAdir/Apr2Feb.nii.gz -prefix $savedir/Qw4_meanhead_brain_Na.nii.gz
3dresample -dxyz 0.2 0.2 0.2 -rmode Cu -prefix $savedir/Qw4_meanhead_brain_Na_200.nii.gz -input $savedir/Qw4_meanhead_brain_Na.nii.gz
3dresample -dxyz 0.3 0.3 0.3 -rmode Cu -prefix $savedir/Qw4_meanhead_brain_Na_300.nii.gz -input $savedir/Qw4_meanhead_brain_Na.nii.gz

brain=$savedir/Qw4_meanhead_brain_Na_200.nii.gz #4
atlas=$savedir/Lemur-Atlas-Apr2Feb-cortexR-label_200.nii.gz #5
mask=$savedir/Lemur-Atlas-Apr2Feb-cortexR-label_200.nii.gz #6
head=$savedir/Qw4_meanhead_Na_200.nii.gz #7
headweight=$savedir/aff3_unionmaskdil3_Na_200.nii.gz #8
basetype=head #9
dofolderoverwrite=no #10
tmpdir=/volatile #11
registerfunctional=no #12
subpipeline=perslice_registration_subpipeline.bash #13
Urad=18.3 #14
brainvol=1600 #15
scale=0.2 #16
T1blood=2800 #17
lambda=0.9 #18
multiplier=6000000 #19
T1guess=1600 #20
mccores=16 #21

rawimdir=NA

for dir in $(find $savedir -mindepth 1 -maxdepth 1 -type d); do
	NIfTIdir=$(readlink -e $dir)
	pipeline_noconversion.bash $rawimdir $NIfTIdir $brain $atlas $mask $head $headweight $basetype $tmpdir $registerfunctional $subpipeline $Urad $brainvol $scale
done
