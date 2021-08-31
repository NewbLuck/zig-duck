const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("Duck", "example.zig");
    lib.setBuildMode(mode);
    lib.install();

    var main_ex = b.addExecutable("example","example.zig");
    main_ex.setBuildMode(mode);
    const ex_step = b.step("example", "Run example");
    ex_step.dependOn(&main_ex.step);

    var lib_tests = b.addTest("duck.zig");
    lib_tests.setBuildMode(mode);
    const test_step = b.step("tests", "Library tests");
    test_step.dependOn(&lib_tests.step);

}
