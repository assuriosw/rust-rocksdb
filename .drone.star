# Assurio-specific build script for use with Drone, our CI system
DOCKER_REGISTRY="537513441174.dkr.ecr.us-east-2.amazonaws.com"

TARGETS = [
        { "os": "linux", "arch": "arm64" },
        { "os": "linux", "arch": "arm64" },
        { "os": "windows", "arch": "amd64" }
        ]

def private_docker_image(image):
    return DOCKER_REGISTRY + "/" + image

def pipeline(arch, os, steps):
  if os == "windows":
      typ = "exec"
  else:
      typ = "docker"

  return {
    "kind": "pipeline",
    "type": typ,
    "name": "build-{os}-{arch}".format(os = os, arch = arch),
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
                    "git submodule update --init --recursive"
                ]
            }

def rust_build_step(arch, os):
    commands = [
	    "cargo version",
	    "cargo check",
            "cargo build",
            "cargo test"
    ]

    return       {
            "name": "build",
            "image": private_docker_image("assurio-rust:{os}-{arch}-latest".format(os = os, arch = arch)),
            "pull": "always",
            "commands": commands
            }

def rust_build_pipelines():
    pipelines = []
    for target in TARGETS:
        steps = [ git_clone_submodules_step() , rust_build_step(target['arch'], target['os']) ]
        pipelines += [ pipeline(target['arch'], target['os'], steps) ]

    return pipelines

def main(ctx):
    return rust_build_pipelines()
