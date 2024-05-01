
## Setup (3 steps)

cd /
git clone https://github.com/levipereira/yolov9-qat.git
cd /yolov9-qat
./patch_yolov9.sh /yolov9

cd /yolov9-qat
./install_dependencies.sh --defaults
cd /yolov9

cd /yolov9
bash scripts/get_coco.sh
wget https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-c-converted.pt
wget https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-e-converted.pt

## Fix COCO paths
# When reaching the quantization step, the line
#    python3 qat.py quantize --weights yolov9-c-converted.pt  --name yolov9_qat --exist-ok
# fails with error "Dataset not found, missing paths ['/datasets/coco/val2017.txt']".
#It seems that the default coco.yaml comes with the path path: ../datasets/coco  # dataset root dir, while the dataset is actually in /yolov9/coco
# Replacing with path: /yolov9/coco  # dataset root dir in coco.yaml fixes this.
cp data/coco.yaml data/coco.yaml.bak
sed -i 's/path: \.\.\/datasets\/coco/path: \/yolov9\/coco/g' data/coco.yaml

## Quantize
#python3 qat.py quantize --weights yolov9-c-converted.pt  --name yolov9_qat --exist-ok
python3 qat.py quantize --weights yolov9-c-converted.pt
python3 qat.py quantize --weights yolov9-c-converted.pt --imgsz 1280 --project runs/qat_yolov9c_1280 --name qat

## Sensitive layer analysis
#python qat.py sensitive --weights yolov9-c-converted.pt --name yolov9_qat_sensitive --exist-ok
python qat.py sensitive --weights yolov9-c-converted.pt

## Evaluate QAT model
python3 qat.py eval --weights runs/qat/yolov9_qat/weights/qat_best_yolov9-c-converted.pt

# fix [05/01/2024-10:36:56] [TRT] [E] 6: The engine plan file is not compatible with this version of TensorRT, expecting library version 10.0.1.6 got 10.0.0.6, please rebuild.
pip install tensorrt==10.0.1

# this generatea the onnx and the engine
./scripts/val_trt.sh runs/qat/yolov9_qat/weights/qat_best_yolov9-c-converted.pt data/coco.yaml 640

## Generate TensoRT Profiling and SVG image
#skip

## Export ONNX
python3 export_qat.py --weights runs/qat/yolov9_qat/weights/qat_best_yolov9-c-converted.pt --include onnx --dynamic --simplify --inplace
python3 export_qat.py  --weights runs/qat/yolov9_qat/weights/qat_best_yolov9-c-converted.pt --include onnx_end2end

## Benchmark


# Separately
/usr/src/tensorrt/bin/trtexec --onnx=qat_best_yolov9-c-converted-end2end.onnx --int8 --saveEngine=qat_best_yolov9-c-converted-end2end.onnx_fp16 --shapes=images:1x3x640x640



# Altogether
#!/bin/bash
set -e
BASEMODEL=yolov9-c
IMGSZ=960
NAME=qat
# ---
PTMODEL=$BASEMODEL-converted.pt
PROJECT=runs/qat_$BASEMODEL_$IMGSZ
BEST_WEIGHTS=$PROJECT/$NAME/weights/qat_best_$PTMODEL
# ---
python3 qat.py quantize --weights $PTMODEL --imgsz $IMGSZ --project $PROJECT --name $NAME
python3 qat.py eval --weights $BEST_WEIGHTS  --imgsz $IMGSZ --project $PROJECT --name $NAME
python3 export_qat.py  --weights $BEST_WEIGHTS --include onnx_end2end
