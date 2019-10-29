# Assurio-specific build script for use with Drone, our CI system
DOCKER_REGISTRY="537513441174.dkr.ecr.us-east-2.amazonaws.com"

TARGETS = [
        { "os": "linux", "arch": "amd64", "include_unstable_rust": True },
        { "os": "linux", "arch": "arm64" , "include_unstable_rust": False },
        { "os": "windows", "arch": "amd64" , "include_unstable_rust": False }
        ]

CHECK_TARGET = { "os": "linux", "arch": "amd64"}

def private_docker_image(image):
    return DOCKER_REGISTRY + "/" + image

def rust_pipeline_name(name, target):
    return "{name}-{os}-{arch}".format(name = name, os = target['os'], arch = target['arch'])

# The check pipeline runs first and does quick checks of syntax and form
# The build steps all depend on this one, so if there's a build error here we don't even bother
# spinning up runners for the other targets
def rust_pipeline(name, target, steps):
  pipeline = {
    "kind": "pipeline",
    "name": rust_pipeline_name(name, target),
    "platform": {
      "os": target['os'],
      "arch": target['arch']
    },
    "steps": steps
  }

  # on Windows we use the exec runner with a Windows image that already has the Rust toolchain
  # on Linux we use a docker container for the same purpose
  if target['os'] == "windows":
      pipeline["type"] = "exec"
  else:
      pipeline["type"] = "docker"

  return pipeline

def rust_check_pipeline():
    steps = [ git_clone_submodules_step(CHECK_TARGET) , rust_check_step(CHECK_TARGET) ]

    return rust_pipeline("check", CHECK_TARGET, steps)

def rust_build_pipeline(target):
    steps = [ git_clone_submodules_step(target) , rust_build_step(target) ]

    if target['include_unstable_rust']:
        for toolchain in [ "beta", "nightly" ]:
            steps += [
                      rust_step("build-{tc}".format(tc = toolchain), target,
                                [ "cargo +{tc} build --all-targets".format(tc = toolchain)])
                      ]

    pipeline = rust_pipeline("build", target, steps)

    # All build pipelines should wait until the check pipeline finishes
    #pipeline["depends_on"] = [ rust_pipeline_name("check", CHECK_TARGET) ]

    return pipeline

def git_clone_submodules_step(target):
    step = {
        "name": "drone_doesnt_support_submodules_wtf",
        "commands": [
                "git submodule update --init --recursive"
        ]
    }

    if target['os'] != 'windows':
        step["image"] = private_docker_image("assurio-rust:{os}-{arch}-latest".format(os = target['os'], arch = target['arch']))

    return step

def rust_step(name, target, commands):
    step = {
        "name": name,
        "commands": commands,
        "depends_on": [ "drone_doesnt_support_submodules_wtf" ]
    }

    if target['os'] != 'windows':
        step["image"] = private_docker_image("assurio-rust:{os}-{arch}-latest".format(os = target['os'], arch = target['arch']))
        step["pull"] = "always"

    return step

def rust_build_step(target, toolchain = "stable"):
    commands = [
        #"dir C:\\ProgramData\\scoop\\apps\\rustup-msvc\\current\\.cargo\\bin",
        #"\"C:\\ProgramData\\scoop\\apps\\rustup-msvc\\current\\.cargo\\bin\\cargo.exe version\"",
        #"\"C:\\ProgramData\\scoop\\apps\\rustup-msvc\\current\\.cargo\\bin\\cargo.exe +stable version\"",
        #"\"C:\\ProgramData\\scoop\\apps\\rustup-msvc\\current\\.cargo\\bin\\cargo.exe +{tc} version\"".format(tc = toolchain),
        "cargo version",
        "rustup show",
        "cargo +{tc} version".format(tc = toolchain),
        "cargo +{tc} build".format(tc = toolchain),
        "cargo +{tc} test".format(tc = toolchain)
    ]

    if target['os'] == 'windows':
        commands = [
                "dir C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin",
                "get-command 'cargo.exe' | select Source",
                "C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin/cargo.exe version"
                ] + commands

    return rust_step("build", target, commands)

def rust_check_step(target):
    commands = [
            "cargo check"
    ]

    return rust_step("check", target, commands)


def rust_pipelines():
    # Start with the check pipeline
    pipelines = [ rust_check_pipeline() ]

    # Followed by build pipelines on each target
    for target in TARGETS:
        steps = [ git_clone_submodules_step(target) , rust_build_step(target) ]
        pipelines += [ rust_build_pipeline(target) ]

    return pipelines

def main(ctx):
    pipelines = rust_pipelines()

    print(pipelines)

    return pipelines
