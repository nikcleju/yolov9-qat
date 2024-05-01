#!/bin/bash

# Usage:
# ./complete_qat_export.sh yolov9-c 640

# Check arguments (2 or 3)
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 BASEMODEL IMGSZ" >&2
    exit 1
fi

set -e
#BASEMODEL=yolov9-c
#IMGSZ=960
BASEMODEL=$1
IMGSZ=$2
BATCHSIZE=${3:-10}
QUANTIZENAME=quantize
EVALNAME=eval
# ---
PTMODEL=$BASEMODEL-converted.pt
PROJECT=runs/qat_$BASEMODEL_$IMGSZ
BEST_WEIGHTS=$PROJECT/$QUANTIZENAME/weights/qat_best_$PTMODEL
# ---
python3 qat.py quantize --weights $PTMODEL --imgsz $IMGSZ --project $PROJECT --name $QUANTIZENAME --batch-size $BATCHSIZE
python3 qat.py eval --weights $BEST_WEIGHTS  --imgsz $IMGSZ --project $PROJECT --name $EVALNAME
python3 export_qat.py  --weights $BEST_WEIGHTS --include onnx_end2end
