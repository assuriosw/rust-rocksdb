# Assurio-specific build script for use with Drone, our CI system
DOCKER_REGISTRY="537513441174.dkr.ecr.us-east-2.amazonaws.com"

def private_docker_image(image):
    return DOCKER_REGISTRY + "/" + image

def main(ctx):
  return {
    "kind": "pipeline",
    "name": "build",
    "steps": [
      {
        "name": "build",
	"image": private_docker_image("assurio-rust:linux-amd64-latest"),
        "commands": [
            "cargo version"
        ]
      }
    ]
  }
