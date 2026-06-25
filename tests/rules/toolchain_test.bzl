"""Analysis tests for the Saxon toolchain."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _saxon_toolchain_probe_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    toolchain = target[platform_common.ToolchainInfo].saxon

    asserts.equals(env, "12.9", toolchain.version)
    asserts.true(env, toolchain.files_to_run.executable != None, "Expected Saxon executable in toolchain")

    return analysistest.end(env)

saxon_toolchain_probe_test = analysistest.make(_saxon_toolchain_probe_impl)
