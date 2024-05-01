#!/bin/bash

# Usage:
# ./complete_qat_export.sh yolov9-c 640

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 BASEMODEL IMGSZ" >&2
    exit 1
fi

set -e
#BASEMODEL=yolov9-c
#IMGSZ=960
BASEMODEL=$1
IMGSZ=$2
NAME=qat
# ---
PTMODEL=$BASEMODEL-converted.pt
PROJECT=runs/qat_$BASEMODEL_$IMGSZ
BEST_WEIGHTS=$PROJECT/$NAME/weights/qat_best_$PTMODEL
# ---
python3 qat.py quantize --weights $PTMODEL --imgsz $IMGSZ --project $PROJECT --name $NAME
python3 qat.py eval --weights $BEST_WEIGHTS  --imgsz $IMGSZ --project $PROJECT --name $NAME
python3 export_qat.py  --weights $BEST_WEIGHTS --include onnx_end2end
