export DCMTK=/usr/cenir/src/dcmtk

export DCMDICTPATH=$DCMTK/lib/dicom.dic
export LD_LIBRARY_PATH=$DCMTK/lib

$DCMTK/bin/storescu -aet DCMTK2  -aec AN_MRSC35181 134.157.205.2 104 $*
