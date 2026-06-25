"""Public providers for the Saxon-HE Bazel toolchain module."""

SaxonHeToolchainInfo = provider(
    doc = "Execution metadata for a Saxon-HE command-line transformer.",
    fields = {
        "files_to_run": "FilesToRunProvider for the Saxon-HE executable target.",
        "version": "Pinned Saxon-HE version string exposed by this toolchain.",
    },
)
