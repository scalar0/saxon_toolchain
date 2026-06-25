"""Reusable Bazel rules for Saxon-backed XSLT transforms."""

def _validate_xml_action(ctx, src, schema, schema_deps, stamp):
    xmllint = ctx.attr._xmllint[DefaultInfo].files_to_run
    ctx.actions.run_shell(
        tools = [xmllint],
        inputs = [src, schema] + schema_deps,
        outputs = [stamp],
        arguments = [xmllint.executable.path, schema.path, src.path, stamp.path],
        command = '"$1" --noout --schema "$2" "$3" && printf \'validated %s against %s\\n\' "$3" "$2" > "$4"',
        mnemonic = "XmlValidate",
        progress_message = "Validating XML: %s" % src.short_path,
    )

def _copy_after_validation_action(ctx, src, out, schema, schema_deps):
    xmllint = ctx.attr._xmllint[DefaultInfo].files_to_run
    ctx.actions.run_shell(
        tools = [xmllint],
        inputs = [src, schema] + schema_deps,
        outputs = [out],
        arguments = [xmllint.executable.path, schema.path, src.path, out.path],
        command = '"$1" --noout --schema "$2" "$3" && cp "$3" "$4"',
        mnemonic = "XmlValidateOutput",
        progress_message = "Validating generated XML: %s" % out.short_path,
    )

def _xslt_transform_impl(ctx):
    toolchain = ctx.toolchains["//toolchain:toolchain_type"].saxon
    out = ctx.outputs.out
    saxon_out = out
    action_outputs = [out]

    if ctx.file.output_schema:
        saxon_out = ctx.actions.declare_file(ctx.label.name + ".unchecked.xml")
        action_outputs = [saxon_out]

    args = ctx.actions.args()
    args.add("-s:%s" % ctx.file.src.path)
    args.add("-xsl:%s" % ctx.file.stylesheet.path)
    args.add("-o:%s" % saxon_out.path)
    for key in sorted(ctx.attr.params):
        args.add("%s=%s" % (key, ctx.attr.params[key]))

    inputs = [ctx.file.src, ctx.file.stylesheet]
    inputs.extend(ctx.files.deps)
    inputs.extend(ctx.files.resources)

    if ctx.file.input_schema:
        input_validation = ctx.actions.declare_file(ctx.label.name + ".input.validated")
        _validate_xml_action(
            ctx = ctx,
            src = ctx.file.src,
            schema = ctx.file.input_schema,
            schema_deps = ctx.files.input_schema_deps,
            stamp = input_validation,
        )
        inputs.append(input_validation)

    ctx.actions.run(
        executable = toolchain.files_to_run,
        tools = [toolchain.files_to_run],
        inputs = inputs,
        outputs = action_outputs,
        arguments = [args],
        mnemonic = "SaxonXsltTransform",
        progress_message = "Transforming XML with Saxon: %s" % out.short_path,
    )

    if ctx.file.output_schema:
        _copy_after_validation_action(
            ctx = ctx,
            src = saxon_out,
            out = out,
            schema = ctx.file.output_schema,
            schema_deps = ctx.files.output_schema_deps,
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
        "input_schema": attr.label(
            allow_single_file = True,
            doc = "Optional XSD used to validate source XML before Saxon runs.",
        ),
        "input_schema_deps": attr.label_list(
            allow_files = True,
            doc = "Schema include/import dependencies for input_schema.",
        ),
        "output_schema": attr.label(
            allow_single_file = True,
            doc = "Optional XSD used to validate generated XML before publishing the declared output.",
        ),
        "output_schema_deps": attr.label_list(
            allow_files = True,
            doc = "Schema include/import dependencies for output_schema.",
        ),
        "_xmllint": attr.label(
            default = Label("@libxml2//:xmllint"),
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = ["//toolchain:toolchain_type"],
)
