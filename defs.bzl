"""Public Starlark API for the Saxon toolchain ruleset."""

load("//:providers.bzl", _SaxonToolchainInfo = "SaxonToolchainInfo")
load("//:xml_rules.bzl", _xml_validate = "xml_validate")
load("//:xslt_rules.bzl", _xslt_transform = "xslt_transform")

SaxonToolchainInfo = _SaxonToolchainInfo
xml_validate = _xml_validate
xslt_transform = _xslt_transform
