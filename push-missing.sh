#!/bin/bash
echo "🚀 Pushing missing blueprints to Docker Hub..."
BLUEPRINTS="python node fullstack web devops go php java"

for bp in $BLUEPRINTS; do
    echo "================================"
    echo "Pushing: $bp"
    echo "================================"
    
    docker push lyskdot/devbox-$bp:latest
    docker push lyskdot/devbox-$bp:1.2.0
    docker push lyskdot/devbox-$bp:1.2
    docker push lyskdot/devbox-$bp:1
    
    echo "✅ Successfully pushed devbox-$bp"
done

echo "================================"
echo "✅ ALL MISSING PUSHES COMPLETED!"
echo "================================"
