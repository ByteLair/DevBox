#!/bin/bash

# Blueprints que faltam
BLUEPRINTS="go rust php ruby java"

for BLUEPRINT in $BLUEPRINTS; do
    echo "================================"
    echo "Building: $BLUEPRINT"
    echo "================================"
    
    cd blueprints/$BLUEPRINT
    
    # Build image
    docker build -t lyskdot/devbox-$BLUEPRINT:latest \
                 -t lyskdot/devbox-$BLUEPRINT:1.2.0 \
                 -t lyskdot/devbox-$BLUEPRINT:1.2 \
                 -t lyskdot/devbox-$BLUEPRINT:1 .
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to build $BLUEPRINT"
        exit 1
    fi
    
    echo "✅ Successfully built devbox-$BLUEPRINT"
    
    # Push all tags
    echo "Pushing: $BLUEPRINT"
    docker push lyskdot/devbox-$BLUEPRINT:latest
    docker push lyskdot/devbox-$BLUEPRINT:1.2.0
    docker push lyskdot/devbox-$BLUEPRINT:1.2
    docker push lyskdot/devbox-$BLUEPRINT:1
    
    echo "✅ Successfully pushed devbox-$BLUEPRINT"
    
    cd ../..
done

echo "================================"
echo "✅ ALL BUILDS COMPLETED!"
echo "================================"
