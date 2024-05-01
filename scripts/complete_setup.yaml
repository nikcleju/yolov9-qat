#!/bin/bash

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
