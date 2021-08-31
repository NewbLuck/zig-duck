const std = @import("std");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

pub const Trait = enum {
    integral,
    float,
    number,
    signed_int,   
    unsigned_int,
    slice,
    string,
    container,
    indexable,
    not_optional,
    optional,
    pointer,
    single_item_pointer,
    many_item_pointer,
    any,
};

pub const Prop = union(enum) {
    trait:Trait,
    fixed_type:type
};

pub const Field = struct {
    name:[]const u8 = undefined,
    prop:?Prop = null,
    child_prop:?Prop = null,
};

pub const Fn = struct {
    name:[]const u8 = undefined,
    ret_prop:?Prop = null,
    retchild_prop:?Prop = null,
    arg_count:?usize = null,
    args:?[]const Prop = null,
};

pub fn Type(comptime T:anytype,comptime rules:anytype) type {
    return struct {
        const Self = @This();

        fn traitCheck(comptime ft:type,comptime trait:Trait,comptime name:[]const u8) void {
            switch(trait) {
                .integral => {
                    if(!std.meta.trait.isIntegral(ft)) {
                        @compileError("Field '" ++ name ++ "' is not an integral type");
                    }
                },
                .float => {
                    if(!std.meta.trait.isFloat(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a float type");
                    }
                },
                .number => {
                    if(!std.meta.trait.isNumber(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a number type");
                    }
                },
                .signed_int => {
                    if(!std.meta.trait.isSignedInt(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a signed integer");
                    }
                },
                .unsigned_int => {
                    if(!std.meta.trait.isUnsignedInt(ft)) {
                        @compileError("Field '" ++ name ++ "' is not an unsigned integer");
                    }
                },
                .slice => {
                    if(!std.meta.trait.isSlice(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a slice");
                    }
                },
                .string => {
                    if(!std.meta.trait.isZigString(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a Zig string");
                    }
                },
                .container => {
                    if(!std.meta.trait.isContainer(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a container");
                    }
                },
                .indexable => {
                    if(!std.meta.trait.isIndexable(ft)) {
                        @compileError("Field '" ++ name ++ "' is not indexable");
                    }
                },
                .optional => {
                    if(!std.meta.trait.is(.Optional)(ft)) {
                        @compileError("Field '" ++ name ++ "' is not optional");
                    }
                },
                .not_optional => {
                    if(std.meta.trait.is(.Optional)(ft)) {
                        @compileError("Field '" ++ name ++ "' is optional");
                    }
                },
                .pointer => {
                    if(!std.meta.trait.is(.Pointer)(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a pointer");
                    }
                },
                .single_item_pointer => {
                    if(!std.meta.trait.isSingleItemPtr(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a single-item pointer");
                    }
                },
                .many_item_pointer => {
                    if(!std.meta.trait.isManyItemPtr(ft)) {
                        @compileError("Field '" ++ name ++ "' is not a many-item pointer");
                    }
                },
                else => { },
            }
        }

        fn propCheck (comptime name:[]const u8,comptime prop:Prop,comptime fld_type:type) void {
            switch (prop) {
                .trait => |trait| {
                    traitCheck(fld_type,trait,name);
                },
                .fixed_type => |ftype| {
                    if(ftype != fld_type) {
                        @compileError("Expected "  ++ name ++ " as " ++ @typeName(ftype) ++ ", found " ++ @typeName(fld_type) ++ " instead.");
                    }
                },
            }
        }

        pub fn check () void {
            comptime {
                inline for(rules) |rule| {
                    switch(@TypeOf(rule)) {
                        Field => {
                            // Test field name
                            if(!@hasField(T,rule.name)) {
                                @compileError("No field matching name " ++ rule.name);
                            } 
                            const fld_idx = std.meta.fieldIndex(T,rule.name).?;
                            const fld_type = std.meta.fields(T)[fld_idx].field_type;
                            // Test field type
                            if(rule.prop) |prop| {
                                propCheck(rule.name,prop,fld_type);
                            }
                            // Test field child type
                            if(rule.child_prop) |prop| {
                                switch (@typeInfo(fld_type)) {
                                    .Array, .Vector, .Pointer, .Optional => {
                                        const chld_type = std.meta.Child(fld_type);
                                        propCheck(rule.name ++ "(child)",prop,chld_type);
                                    },
                                    else => {
                                        @compileError("Type does not have children even though one was defined");
                                    },
                                }
                            }
                        },
                        Fn => {
                            // Test name
                            if(!std.meta.trait.hasFn(rule.name)(T)) {
                                @compileError("No fn named " ++ rule.name);
                            } 
                            const decl = std.meta.declarationInfo(T,rule.name);
                            const fn_decl = decl.data.Fn;
                            const rtype = fn_decl.return_type;
                            // Test return
                            if(rule.ret_prop) |rprop| {
                                propCheck(rule.name ++ "(return)",rprop,rtype);
                            }
                            // Test return child type
                            if(rule.retchild_prop) |prop| {
                                switch(@typeInfo(rtype)) {
                                    .Array, .Vector, .Pointer, .Optional => {
                                        const chld_type = std.meta.Child(rtype);
                                        propCheck(rule.name ++ "(return child)",prop,chld_type);
                                    },
                                    else => {
                                        @compileError("Return type does not have children even though one was defined");
                                    },
                                }
                            }
                            // Test args
                            const args_t = std.meta.ArgsTuple(fn_decl.fn_type);
                            var tfld = std.meta.fields(args_t);
                            if(rule.arg_count) |nargs| {
                                if(tfld.len != nargs) {
                                    @compileError("Incorrect argument count: " ++ rule.name);
                                }
                            }
                            if(rule.args) |args| {
                                inline for (tfld) |fld,ix| {
                                    if(ix >= args.len) continue;
                                    propCheck(rule.name ++ ":" ++ fld.name,args[ix],fld.field_type);
                                }
                            }
                        },
                        else => {
                            @compileError("This is not a duck.");
                        },
                    }
                }
            }
        }
    };
}

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

///////////////////////////////////////////////////////////////////////////////

test "Basic / Namw" {
    comptime Type(TestStruct, .{
        Field { .name = "opt_u32" },
        Field { .name = "a_f32" },
        Field { .name = "strct_vec" },
        Field { .name = "just_name" },
        Field { .name = "string" },
        Fn { .name = "testFn" },
        Fn { .name = "nameFn" }
    }).check();
}
test "Complex" {
    comptime Type(TestStruct, .{
        Field { .name = "opt_u32", .prop = .{ .trait = .optional }, .child_prop = .{ .trait = .integral } },
        Field { .name = "a_f32", .prop = .{ .fixed_type = f32 } },
        Field { .name = "strct_vec", .prop = .{ .trait = .container } },
        Field { .name = "just_name" },
        Field { .name = "string", .prop = .{ .trait = .string } },
        Fn { .name = "testFn", .ret_prop = .{ .trait = .signed_int }, .arg_count = 3, 
            .args = &[_]Prop{
                .{ .trait = .integral },
                .{ .fixed_type = bool },
                .{ .fixed_type = TestVec },
            }
        },
        Fn { .name = "nameFn", .ret_prop = .{ .fixed_type = void } }
    }).check();
}
test "Types & Fixed Type Children" {
    const T1 = struct {
        slice:[]i16 = undefined,
        string:[]const u8 = undefined,
        mptr:[*]f32 = undefined,
        sptr:*f32 = undefined,
        idx:[10]u8 = undefined,
        opt:?usize = undefined,
    };
    comptime Type(T1,.{
        Field { .name = "slice", .prop = .{ .trait = .slice }, .child_prop = .{ .fixed_type = i16 } },
        Field { .name = "string", .prop = .{ .trait = .string }, .child_prop = .{ .fixed_type = u8 } },
        Field { .name = "mptr", .prop = .{ .trait = .many_item_pointer }, .child_prop = .{ .fixed_type = f32 } },
        Field { .name = "sptr", .prop = .{ .trait = .single_item_pointer }, .child_prop = .{ .fixed_type = f32 } },
        Field { .name = "idx", .prop = .{ .trait = .indexable }, .child_prop = .{ .fixed_type = u8 } },
        Field { .name = "opt", .prop = .{ .trait = .optional }, .child_prop = .{ .fixed_type = usize } },
        Field { .name = "idx", .prop = .{ .trait = .not_optional }, .child_prop = .{ .fixed_type = u8 } },
    }).check();
}
