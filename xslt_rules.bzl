"""Reusable Bazel rules for Saxon-backed XSLT transforms."""

def _xslt_transform_impl(ctx):
    toolchain = ctx.toolchains["//toolchain:toolchain_type"].saxon
    out = ctx.outputs.out

    args = ctx.actions.args()
    args.add("-s:%s" % ctx.file.src.path)
    args.add("-xsl:%s" % ctx.file.stylesheet.path)
    args.add("-o:%s" % out.path)
    for key in sorted(ctx.attr.params):
        args.add("%s=%s" % (key, ctx.attr.params[key]))

    inputs = [ctx.file.src, ctx.file.stylesheet]
    inputs.extend(ctx.files.deps)
    inputs.extend(ctx.files.resources)

    ctx.actions.run(
        executable = toolchain.files_to_run,
        tools = [toolchain.files_to_run],
        inputs = inputs,
        outputs = [out],
        arguments = [args],
        mnemonic = "SaxonXsltTransform",
        progress_message = "Transforming XML with Saxon: %s" % out.short_path,
    )

    return [DefaultInfo(files = depset([out]))]

xslt_transform = rule(
    implementation = _xslt_transform_impl,
    doc = "Runs a Saxon-backed XSLT transform with declared inputs and one XML output.",
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Source XML file.",
        ),
        "stylesheet": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Main XSLT stylesheet.",
        ),
        "out": attr.output(
            mandatory = True,
            doc = "Generated transform output file.",
        ),
        "deps": attr.label_list(
            allow_files = True,
            doc = "Declared XSLT include/import dependencies.",
        ),
        "resources": attr.label_list(
            allow_files = True,
            doc = "Additional declared files readable by the transform.",
        ),
        "params": attr.string_dict(
            doc = "String parameters passed to Saxon in deterministic key order.",
        ),
    },
    toolchains = ["//toolchain:toolchain_type"],
)
