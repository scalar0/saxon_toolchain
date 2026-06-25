"""Toolchain definitions for running Saxon-HE under Bazel."""

load("//:providers.bzl", "SaxonHeToolchainInfo")

def _saxon_he_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            saxon_he = SaxonHeToolchainInfo(
                files_to_run = ctx.attr.saxon[DefaultInfo].files_to_run,
                version = ctx.attr.version,
            ),
        ),
    ]

saxon_he_toolchain = rule(
    implementation = _saxon_he_toolchain_impl,
    doc = "Wraps a Saxon-HE executable target as a Bazel toolchain.",
    attrs = {
        "saxon": attr.label(
            default = Label("//:saxon_he_cli"),
            executable = True,
            cfg = "exec",
            doc = "Executable Saxon-HE command-line target.",
        ),
        "version": attr.string(
            default = "12.9",
            doc = "Pinned Saxon-HE version exposed for analysis tests and diagnostics.",
        ),
    },
)
