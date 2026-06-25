"""Toolchain definitions for running Saxon under Bazel."""

load("//:providers.bzl", "SaxonToolchainInfo")

def _saxon_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            saxon = SaxonToolchainInfo(
                files_to_run = ctx.attr.saxon[DefaultInfo].files_to_run,
                version = ctx.attr.version,
            ),
        ),
    ]

saxon_toolchain = rule(
    implementation = _saxon_toolchain_impl,
    doc = "Wraps a Saxon executable target as a Bazel toolchain.",
    attrs = {
        "saxon": attr.label(
            default = Label("//:saxon_cli"),
            executable = True,
            cfg = "exec",
            doc = "Executable Saxon command-line target.",
        ),
        "version": attr.string(
            default = "12.9",
            doc = "Pinned Saxon-HE version exposed for analysis tests and diagnostics.",
        ),
    },
)
