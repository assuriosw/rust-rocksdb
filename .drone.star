# Assurio-specific build script for use with Drone, our CI system
DOCKER_REGISTRY="537513441174.dkr.ecr.us-east-2.amazonaws.com"

def private_docker_image(image):
    return DOCKER_REGISTRY + "/" + image

def pipeline(arch, os, steps):
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "foo",
    "platform": {
      "os": os,
      "arch": arch
    },
    "steps": steps
  }

def git_clone_submodules_step():
    return {
            "name": "drone_missing_basic_functionality_number_1523_git_submodule_fetching",
            "image": "alpine/git",
            "commands": [
                    "git submodule update --recursive --remote"
                ]
            }

def rust_build_step(arch, os, commands):
    return       {
            "name": "build",
            "image": private_docker_image("assurio-rust:{os}-{arch}-latest".format(os = os, arch = arch)),
            "commands": commands
            }


def main(ctx):
    commands = [
	    "cargo version",
	    "cargo check"
    ]

    steps = [
            git_clone_submodules_step(),
            rust_build_step("amd64", "linux", commands)
            ]

    return pipeline("amd64", "linux", steps)
