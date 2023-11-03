# Re-export of Bazel rules with repository-wide defaults

load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@build_bazel_rules_nodejs//:index.bzl", _pkg_npm = "pkg_npm")
load("@io_bazel_rules_sass//:defs.bzl", _npm_sass_library = "npm_sass_library", _sass_binary = "sass_binary", _sass_library = "sass_library")
load("@npm//@angular/bazel:index.bzl", _ng_module = "ng_module", _ng_package = "ng_package")
load("@npm//@angular/build-tooling/bazel/integration:index.bzl", _integration_test = "integration_test")
load("@npm//@angular/build-tooling/bazel/karma:index.bzl", _karma_web_test_suite = "karma_web_test_suite")
load("@npm//@angular/build-tooling/bazel/esbuild:index.bzl", _esbuild = "esbuild", _esbuild_config = "esbuild_config")
load("@npm//@angular/build-tooling/bazel/spec-bundling:index.bzl", _spec_bundle = "spec_bundle")
load("@npm//@angular/build-tooling/bazel/http-server:index.bzl", _http_server = "http_server")
load("@npm//@angular/build-tooling/bazel:extract_js_module_output.bzl", "extract_js_module_output")
load("@npm//@bazel/jasmine:index.bzl", _jasmine_node_test = "jasmine_node_test")
load("@npm//@bazel/protractor:index.bzl", _protractor_web_test_suite = "protractor_web_test_suite")
load("@npm//@bazel/concatjs:index.bzl", _ts_library = "ts_library")
load("@npm//tsec:index.bzl", _tsec_test = "tsec_test")
load("//:packages.bzl", "NO_STAMP_NPM_PACKAGE_SUBSTITUTIONS", "NPM_PACKAGE_SUBSTITUTIONS")
load("//:pkg-externals.bzl", "PKG_EXTERNALS")

# load("//tools/markdown-to-html:index.bzl", _markdown_to_html = "markdown_to_html")
load("//tools/angular:index.bzl", "LINKER_PROCESSED_FW_PACKAGES")

_DEFAULT_TSCONFIG_BUILD = "//src:bazel-tsconfig-build.json"
_DEFAULT_TSCONFIG_TEST = "//src:tsconfig-test"

npmPackageSubstitutions = select({
    "//tools:stamp": NPM_PACKAGE_SUBSTITUTIONS,
    "//conditions:default": NO_STAMP_NPM_PACKAGE_SUBSTITUTIONS,
})

# Re-exports to simplify build file load statements
# markdown_to_html = _markdown_to_html
integration_test = _integration_test
esbuild = _esbuild
esbuild_config = _esbuild_config
http_server = _http_server

def ng_module(
        deps = [],
        srcs = [],
        tsconfig = None,
        testonly = False,
        **kwargs):
    if not tsconfig:
        tsconfig = _DEFAULT_TSCONFIG_BUILD

    # Compute an AMD module name for the target.
    module_name = None

    local_deps = [
        # Add tslib because we use import helpers for all public packages.
        "@npm//tslib",
        "@npm//@angular/platform-browser",
    ]

    # Append given deps only if they're not in the default set of deps
    for d in deps:
        if d not in local_deps:
            local_deps = local_deps + [d]

    _ng_module(
        srcs = srcs,
        # `module_name` is used for AMD module names within emitted JavaScript files.
        module_name = module_name,
        # We use the module name as package name, so that the target can be resolved within
        # NodeJS executions, by activating the Bazel NodeJS linker.
        # See: https://github.com/bazelbuild/rules_nodejs/pull/2799.
        package_name = module_name,
        strict_templates = True,
        deps = local_deps,
        tsconfig = tsconfig,
        testonly = testonly,
        **kwargs
    )

    # if module_name and not testonly:
    #     _make_tsec_test(kwargs["name"])
