"""Public providers for the Saxon Bazel toolchain module."""

SaxonToolchainInfo = provider(
    doc = "Execution metadata for a Saxon command-line transformer.",
    fields = {
        "files_to_run": "FilesToRunProvider for the Saxon executable target.",
        "version": "Pinned Saxon-HE version string exposed by this toolchain.",
    },
)
