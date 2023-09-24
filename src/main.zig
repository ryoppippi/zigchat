const std = @import("std");
const builtin = @import("builtin");
const process = std.process;

// https://gist.github.com/leecannon/d6f5d7e5af5881c466161270347ce84d
pub const log_level: std.log.Level = switch (builtin.mode) {
    .Debug => .debug,
    .ReleaseSafe => .notice,
    .ReleaseFast => .err,
    .ReleaseSmall => .err,
};

const uri = std.Uri.parse("https://api.openai.com/v1/chat/completions") catch unreachable;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const allocator = arena.allocator();

    // get the message from the command line
    const message = try getArgument(allocator);
    defer allocator.free(message);

    // get the key from the environment
    const OPENAI_API_KEY = try getOpenAIKey(allocator);
    defer allocator.free(OPENAI_API_KEY);

    var client: std.http.Client = .{ .allocator = allocator };
    defer client.deinit();

    var headers: std.http.Headers = .{ .allocator = allocator };
    defer headers.deinit();

    const bearer = try std.fmt.allocPrint(allocator, "Bearer {s}", .{OPENAI_API_KEY});
    defer allocator.free(bearer);

    try headers.append("Content-Type", "application/json");
    try headers.append("Authorization", bearer);

    // https://platform.openai.com/docs/api-reference/making-requests
    const json = try std.json.stringifyAlloc(
        allocator,
        Request{
            .model = "gpt-3.5-turbo",
            .messages = &[_]Message{
                .{ .role = "user", .content = message },
            },
        },
        .{},
    );
    defer allocator.free(json);

    std.log.info("json: {s}\n", .{json});

    var res = try client.fetch(allocator, .{
        .method = .POST,
        .location = .{ .uri = uri },
        .headers = headers,
        .payload = .{ .string = json },
    });
    defer res.deinit();

    if (res.body) |body| {
        std.log.info("body: {s}\n", .{body});

        const result = try std.json.parseFromSlice(
            Result,
            allocator,
            body,
            .{ .ignore_unknown_fields = true },
        );
        defer result.deinit();

        var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
        const stdout = bw.writer();

        try stdout.print("{s}", .{result.value.choices[0].message.content});

        try bw.flush();
    } else {
        std.log.err("no body\n", .{});
        std.log.err("status: {any}\n", .{res.status});
    }
}

const Request = struct {
    model: []const u8,
    messages: []const Message,
};

const Message = struct {
    role: []const u8,
    content: []const u8,
};

const Result = struct {
    id: []const u8,
    object: []const u8,
    created: u32,
    model: []const u8,
    choices: []const Choice,
};

const Choice = struct {
    index: u32,
    finish_reason: []const u8,
    message: Message,
};

fn getOpenAIKey(allocator: std.mem.Allocator) ![]const u8 {
    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    const key = if (env_map.get("OPENAI_API_KEY")) |key| key else {
        std.log.err("OPENAI_API_KEY not set\n", .{});
        unreachable;
    };

    return try allocator.dupe(u8, key);
}

fn getArgument(allocator: std.mem.Allocator) ![]const u8 {
    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len == 1) {
        return try allocator.dupe(u8, "Hello, I'm a user.");
    } else {
        return try allocator.dupe(u8, args[1]);
    }
}
