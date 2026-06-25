"""Small test-only rule proving consumers can execute Saxon through the toolchain."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _saxon_transform_impl(ctx):
    toolchain = ctx.toolchains["//toolchain:toolchain_type"].saxon_he
    out = ctx.outputs.out

    args = ctx.actions.args()
    args.add("-s:%s" % ctx.file.src.path)
    args.add("-xsl:%s" % ctx.file.stylesheet.path)
    args.add("-o:%s" % out.path)
    for key in sorted(ctx.attr.params.keys()):
        args.add("%s=%s" % (key, ctx.attr.params[key]))

    ctx.actions.run(
        executable = toolchain.files_to_run,
        tools = [toolchain.files_to_run],
        inputs = [ctx.file.src, ctx.file.stylesheet],
        outputs = [out],
        arguments = [args],
        mnemonic = "SaxonHeSmokeTransform",
        progress_message = "Testing Saxon-HE transform: %s" % out.short_path,
    )

    return [DefaultInfo(files = depset([out]))]

saxon_transform = rule(
    implementation = _saxon_transform_impl,
    attrs = {
        "src": attr.label(mandatory = True, allow_single_file = True),
        "stylesheet": attr.label(mandatory = True, allow_single_file = True),
        "out": attr.output(mandatory = True),
        "params": attr.string_dict(),
    },
    toolchains = ["//toolchain:toolchain_type"],
)

def _saxon_toolchain_probe_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    toolchain = target[platform_common.ToolchainInfo].saxon_he

    asserts.equals(env, "12.9", toolchain.version)
    asserts.true(env, toolchain.files_to_run.executable != None, "Expected Saxon executable in toolchain")

    return analysistest.end(env)

saxon_toolchain_probe_test = analysistest.make(_saxon_toolchain_probe_impl)
