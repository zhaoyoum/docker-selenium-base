#!/bin/bash
echo "Downloading manifest-tool."
#MT_VERSION=$(curl https://api.github.com/repos/estesp/manifest-tool/releases | jq '.[].tag_name' -r | head -n1)
MT_VERSION=v1.0.3
curl -O -sL https://github.com/estesp/manifest-tool/releases/download/${MT_VERSION}/manifest-tool-linux-arm64
mv manifest-tool-linux-arm64 /usr/bin/manifest-tool
chmod +x /usr/bin/manifest-tool
manifest-tool --version

echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
manifest-tool push from-args \
  --platforms linux/arm64 \
  --template "$REGISTRY/$IMAGE:$VERSION-ARCH" \
  --target "$REGISTRY/$IMAGE:$VERSION"
if [ "${CIRCLE_BRANCH}" == 'master' ]; then
  manifest-tool push from-args \
    --platforms linux/arm64 \
    --template "$REGISTRY/$IMAGE:$VERSION-ARCH" \
    --target "$REGISTRY/$IMAGE:latest"
fi

manifest-tool inspect "$REGISTRY/$IMAGE:$VERSION"
