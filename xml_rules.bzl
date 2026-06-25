"""Generic XML validation rules backed by libxml2/xmllint."""

def _xml_validation_action(ctx, src, schema, schema_deps, stamp):
    xmllint = ctx.attr._xmllint[DefaultInfo].files_to_run
    command = '"$1" --noout --schema "$2" "$3" && printf \'validated %s against %s\\n\' "$3" "$2" > "$4"'
    ctx.actions.run_shell(
        tools = [xmllint],
        inputs = [src, schema] + schema_deps,
        outputs = [stamp],
        arguments = [xmllint.executable.path, schema.path, src.path, stamp.path],
        command = command,
        mnemonic = "XmlValidate",
        progress_message = "Validating XML: %s" % src.short_path,
    )

def _xml_validate_impl(ctx):
    out = ctx.outputs.out
    _xml_validation_action(
        ctx = ctx,
        src = ctx.file.src,
        schema = ctx.file.schema,
        schema_deps = ctx.files.schema_deps,
        stamp = out,
    )
    return [DefaultInfo(files = depset([out]))]

_xml_validate = rule(
    implementation = _xml_validate_impl,
    doc = "Validates an XML file against an XSD schema using libxml2/xmllint and emits a stamp file.",
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "XML file to validate.",
        ),
        "schema": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "XSD schema file.",
        ),
        "schema_deps": attr.label_list(
            allow_files = True,
            doc = "XSD include/import dependencies needed by the schema.",
        ),
        "out": attr.output(
            mandatory = True,
            doc = "Validation stamp output.",
        ),
        "_xmllint": attr.label(
            default = Label("@libxml2//:xmllint"),
            executable = True,
            cfg = "exec",
        ),
    },
)

def xml_validate(name, src, schema, schema_deps = [], out = None, **kwargs):
    """Validate XML against XSD with a deterministic default stamp name."""
    if out == None:
        out = name + ".validated"
    _xml_validate(
        name = name,
        src = src,
        schema = schema,
        schema_deps = schema_deps,
        out = out,
        **kwargs
    )
