const std = @import("std");

pub const Hitbox = struct
{
    Top: i32 = 0,
    Bottom: i32 = 0,
    Left: i32 = 0,
    Right: i32 = 0,
};

pub const HitboxGroup = struct
{
    StartFrame: i32 = 0,
    Duration: i32 = 1,

    HitBoxes: std.ArrayList(Hitbox),

    pub fn Init(allocator: std.mem.Allocator) !HitboxGroup
    {
        return HitboxGroup
        {
            .HitBoxes = std.ArrayList(Hitbox).init(allocator)
        };     
    }

    pub fn IsActiveOnFrame(self: HitboxGroup, frame: i32) bool
    {
        return (frame >= self.StartFrame) and (frame < (self.StartFrame + self.Duration));
    }
};

pub const ActionProperties = struct
{
    Duration: i32 = 0,
    AttackHitboxGroups: std.ArrayList(HitboxGroup),
    VulnerableHitboxGroups: std.ArrayList(HitboxGroup),

    pub fn Init(allocator: std.mem.Allocator) !ActionProperties
    {
        return ActionProperties
        {
            .AttackHitboxGroups = std.ArrayList(HitboxGroup).init(allocator),
            .VulnerableHitboxGroups = std.ArrayList(HitboxGroup).init(allocator),
        };     
    }
};

pub const CharacterProperties = struct
{
    MaxHealth: i32 = 420,
    Actions: std.ArrayList(ActionProperties),

    pub fn Init(allocator: std.mem.Allocator) !CharacterProperties
    {
        return CharacterProperties
        {
            .Actions = std.ArrayList(ActionProperties).init(allocator),
        };     
    }
};

test "Testing resizable array" 
{
    var characterArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var hitboxGroup = HitboxGroup
    {
        .HitBoxes = std.ArrayList(Hitbox).init(characterArenaAllocator.allocator())
    };

    try hitboxGroup.HitBoxes.append(Hitbox{ .Top    = 0,
                                            .Bottom = 0,
                                            .Left   = 200,
                                            .Right  = 400 });

    try std.testing.expect(hitboxGroup.HitBoxes.items.len == 1);
    try std.testing.expect(hitboxGroup.HitBoxes.items[0].Left == 200);
    try std.testing.expect(hitboxGroup.HitBoxes.items[0].Right == 400);
}

test "Test HitboxGroup.IsActiveOnFrame()"
{
    var arenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var hitboxGroup = HitboxGroup
    {
        .StartFrame = 0,
        .Duration = 5,
        .HitBoxes = std.ArrayList(Hitbox).init(arenaAllocator.allocator())
    };

    try std.testing.expect(hitboxGroup.IsActiveOnFrame(0));
    try std.testing.expect(hitboxGroup.IsActiveOnFrame(4));
}