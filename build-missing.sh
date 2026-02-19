#!/bin/bash

# Build only missing blueprints
set -e

BLUEPRINTS=("fullstack" "devops" "go" "java")
VERSION="1.2"

echo "🚀 Building missing blueprints..."
echo ""

for blueprint in "${BLUEPRINTS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Building devbox-$blueprint"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd blueprints/$blueprint
    
    cp ../../entrypoint.sh .
    
    # Build image
    echo "🔨 Building image..."
    docker build -t lyskdot/devbox-$blueprint:latest \
                 -t lyskdot/devbox-$blueprint:$VERSION \
                 -t lyskdot/devbox-$blueprint:1.1 \
                 -t lyskdot/devbox-$blueprint:1 .
    
    echo "✅ Successfully built devbox-$blueprint"
    
    # Push if requested
    if [ "$1" = "push" ]; then
        echo "📤 Pushing to Docker Hub..."
        docker push lyskdot/devbox-$blueprint:latest
        docker push lyskdot/devbox-$blueprint:$VERSION
        docker push lyskdot/devbox-$blueprint:1.1
        docker push lyskdot/devbox-$blueprint:1
        echo "✅ Successfully pushed devbox-$blueprint"
    fi
    
    cd ../..
    echo ""
done

echo "🎉 All missing blueprints completed!"
