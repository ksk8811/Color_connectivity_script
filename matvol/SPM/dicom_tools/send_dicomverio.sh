
export DCMTK=/usr/cenir/src/dcmtk

export DCMDICTPATH=$DCMTK/lib/dicom.dic
export LD_LIBRARY_PATH=$DCMTK/lib

 $DCMTK/bin/storescu -aet DCMTK1 -aec MRC40527 134.157.205.51 104 $*

