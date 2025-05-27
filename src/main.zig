const std = @import("std");
const builtin = @import("builtin");
const process = std.process;
const metadata = @import("metadata");
const http = std.http;
const Client = http.Client;
const Request = http.Client.Request;

const clap = @import("clap");

pub const std_options: std.Options = .{ .log_level = switch (builtin.mode) {
    .Debug => .debug,
    .ReleaseSafe => .warn,
    .ReleaseFast => .err,
    .ReleaseSmall => .err,
} };

comptime {
    _ = std_options;
}

const uri = std.Uri.parse("https://api.openai.com/v1/chat/completions") catch @compileError("invalid uri");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    // init stdout
    var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
    const stdout = bw.writer();

    // get params
    const params = comptime clap.parseParamsComptime(
        \\-h, --help         Display the help
        \\-v, --version      Display the version
        \\<PROMPT>           "prompt to send to the OpenAI API"
        \\
    );

    const parsers = comptime .{
        .PROMPT = clap.parsers.string,
    };
    var diag = clap.Diagnostic{};
    var args_res = try clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = allocator,
    });
    defer args_res.deinit();

    if (args_res.args.help != 0) {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
    if (args_res.args.version != 0) {
        try stdout.print("{s}\n", .{metadata.version});
        return try bw.flush();
    }

    const prompt = args_res.positionals[0] orelse {
        std.log.err("no prompt found\n", .{});
        return error.NoPromptProvided;
    };

    // get the key from the environment
    const OPENAI_API_KEY = try getOpenAIKey(allocator);
    defer allocator.free(OPENAI_API_KEY);

    var client: Client = .{ .allocator = allocator };
    defer client.deinit();

    const bearer = try std.fmt.allocPrint(allocator, "Bearer {s}", .{OPENAI_API_KEY});
    defer allocator.free(bearer);

    const headers: Request.Headers = .{
        .content_type = .{ .override = "application/json" },
        .authorization = .{ .override = bearer },
    };

    // https://platform.openai.com/docs/api-reference/making-requests
    const json = try std.json.stringifyAlloc(
        allocator,
        OpenAIRequest{
            .model = "gpt-3.5-turbo",
            .messages = &[_]Message{
                .{ .role = "user", .content = prompt },
            },
        },
        .{},
    );
    defer allocator.free(json);

    std.log.info("json: {s}\n", .{json});

    var res_array_list = std.ArrayList(u8).init(allocator);
    defer res_array_list.deinit();

    const res = try client.fetch(.{
        .method = .POST,
        .location = .{ .uri = uri },
        .headers = headers,
        .response_storage = .{ .dynamic = &res_array_list },
        .payload = json,
    });

    if (res.status.class() != .success) {
        std.log.err("status: {s}\n", .{res.status.phrase() orelse ""});
        unreachable;
    }

    const body = res_array_list.items;

    if (body.len == 0) {
        std.log.err("no body\n", .{});
        unreachable;
    }

    std.log.info("body: {s}\n", .{body});

    const parsed_body = try std.json.parseFromSlice(
        Result,
        allocator,
        body,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_body.deinit();

    try stdout.print("{s}", .{parsed_body.value.choices[0].message.content});

    try bw.flush();
}

const OpenAIRequest = struct {
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
