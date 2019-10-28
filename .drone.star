# Assurio-specific build script for use with Drone, our CI system
DOCKER_REGISTRY="537513441174.dkr.ecr.us-east-2.amazonaws.com"

def private_docker_image(image):
    return DOCKER_REGISTRY + "/" + image

def rust_build_step(arch, os, commands):
  return {
    "kind": "pipeline",
    "name": "build",
    "platform": {
      "os": os,
      "arch": arch
    },
    "steps": [
      {
        "name": "build",
	"image": private_docker_image("assurio-rust:{os}-{arch}-latest".format(os = os, arch = arch)),
        "commands": commands
	}
    ]
  }

def main(ctx):
    commands = [
	    "cargo version",
	    "cargo check"
    ]

    return rust_build_step("amd64", "linux", commands)
