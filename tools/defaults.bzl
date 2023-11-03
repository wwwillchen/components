# Re-export of Bazel rules with repository-wide defaults

load("@npm//@angular/bazel:index.bzl", _ng_module = "ng_module", _ng_package = "ng_package")

_DEFAULT_TSCONFIG_BUILD = "//src:bazel-tsconfig-build.json"

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
