"""Public Starlark API for the Saxon toolchain ruleset."""

load("//:providers.bzl", _SaxonToolchainInfo = "SaxonToolchainInfo")
load("//:xslt_rules.bzl", _xslt_transform = "xslt_transform")

SaxonToolchainInfo = _SaxonToolchainInfo
xslt_transform = _xslt_transform
