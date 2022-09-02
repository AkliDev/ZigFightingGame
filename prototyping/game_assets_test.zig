const std = @import("std");

test"Test reading file"
{
    const file = try std.fs.cwd().openFile("prototyping/input.txt", .{.read = true}); 
    defer(file.close());

    var buffer: [1024]u8 = undefined;
    var bytesRead = try file.readAll(&buffer);

    var messege = buffer[0..bytesRead];
    std.debug.print("\n{s}\n", .{messege});  
}

test"Test writing file"
{
    const file = try std.fs.cwd().createFile("prototyping/output.txt", .{}); 
    defer(file.close());

    var messege = "A test messege that was wrote!";
    try file.writeAll(messege);    
}

const TestJsonStruct = struct
{
    a: i32,
    b: []const u8
};

test"Test writing a struct to a json file"
{
    var data = TestJsonStruct{.a = 42,.b = "The World!"};

    const file = try std.fs.cwd().createFile("prototyping/testoutput.json", .{}); 
    defer(file.close());

    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var string = std.ArrayList(u8).init(fba.allocator());

    try std.json.stringify(data, .{}, string.writer());
    try file.writeAll(buffer[0..string.items.len]);
}

test"Test parsing a json file"
{
    const file = try std.fs.cwd().openFile("prototyping/testinput.json", .{.read = true}); 
    defer(file.close());

    var buffer: [1024]u8 = undefined;
    var bytesRead = try file.readAll(&buffer);
    var messege = buffer[0..bytesRead]; 
    var stream = std.json.TokenStream.init(messege);
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const data = try std.json.parse(TestJsonStruct, &stream, .{.allocator = fba.allocator()});
   
    try std.testing.expect(data.a == 42);
    try std.testing.expectEqualStrings(data.b, "The World!");
}