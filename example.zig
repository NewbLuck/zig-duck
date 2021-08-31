const std = @import("std");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
const duck = @import("duck.zig");

const TestVec = struct {
    x:f32 = 0.0,
    y:f32 = 0.0,
};

const TestStruct = struct {
    opt_u32:?u32 = undefined,
    a_f32:f32 = undefined,
    just_name:[]const u8 = undefined,
    string:[]const u8 = undefined,
    strct_vec:TestVec = TestVec{},
    pub fn testFn(first:i32,second:bool,third:TestVec) i32 {
        _=first;
        _=second;
        _=third;
        return 0;
    }
    pub fn nameFn(first:i32,second:bool,third:TestVec) void {
        _=first;
        _=second;
        _=third;
    }
};

const BrokenStruct = struct {
    opt_u32:?u33 = undefined,
    a_f32:f32 = undefined,
    just_name:[]const u8 = undefined,
    string:[]const u8 = undefined,
    strct_vec:TestVec = TestVec{},
    pub fn testFn(first:i32,second:bool,third:TestVec) i32 {
        _=first;
        _=second;
        _=third;
        return 0;
    }
    pub fn nameFn(first:i32,second:bool,third:TestVec) void {
        _=first;
        _=second;
        _=third;
    }
};


pub fn testy(comptime T:anytype) void {
    comptime duck.Type(T, .{
        duck.Field { .name = "opt_u32" },
        duck.Field { .name = "a_f32" },
        duck.Field { .name = "strct_vec" },
        duck.Field { .name = "just_name" },
        duck.Field { .name = "string" },
        duck.Fn { .name = "testFn" },
        duck.Fn { .name = "nameFn" }
    }).check();

    std.debug.print("Ok1\n",.{});
}


pub fn fancy(comptime T:anytype) void {
    comptime duck.Type(T, .{
        duck.Field { .name = "opt_u32", .prop = .{ .trait = .optional }, .child_prop = .{ .trait = .integral } },
        duck.Field { .name = "a_f32", .prop = .{ .fixed_type = f32 } },
        duck.Field { .name = "strct_vec", .prop = .{ .trait = .container } },
        duck.Field { .name = "just_name" },
        duck.Field { .name = "string", .prop = .{ .trait = .string } },
        duck.Fn { .name = "testFn", .ret_prop = .{ .trait = .signed_int }, .arg_count = 3, 
            .args = &[_]duck.Prop{
                .{ .trait = .integral },
                .{ .fixed_type = bool },
                .{ .fixed_type = TestVec },
            }
        },
        duck.Fn { .name = "nameFn", .ret_prop = .{ .fixed_type = void } }
    }).check();

    std.debug.print("Ok2\n",.{});

}


pub fn main () !void {
    testy(TestStruct);
    fancy(BrokenStruct);
}


