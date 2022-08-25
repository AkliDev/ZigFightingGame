const std = @import("std");
const assert = std.debug.assert;
const CharacterData = @import("CharacterData.zig");
const Math = @import("utils/Math.zig");

// Get all the active vulnerable boxes and translated by characters position.
fn GetVulerableBoxes(hitboxPool: []CharacterData.Hitbox, action: CharacterData.ActionProperties, frame: i32, position: Math.IntVector2) usize
{
    var poolIndex:usize = 0;

    // Find all active hitboxes
    for (action.VulnerableHitboxGroups.items) |hitboxGroup|
    {
        if(hitboxGroup.IsActiveOnFrame(frame))
        {
            for(hitboxGroup.HitBoxes.items) | hitbox |
            {
                assert(poolIndex <= hitboxPool.len);

                //If we exceed the hitbox pool size, return the size of the hitbox pool and write no more hiboxes
                if(poolIndex >= hitboxPool.len)
                {
                    return hitboxPool.len;
                }

                //Translate hitbox by character position
                hitboxPool[poolIndex] = CharacterData.Hitbox{.Top     = hitbox.Top + position.y,
                                                             .Bottom  = hitbox.Bottom + position.y,
                                                             .Left    = hitbox.Left + position.x,
                                                             .Right   = hitbox.Right + position.x};

                poolIndex += 1;
            }
        }
    }

    return poolIndex;
}

test "Test getting translated hitboxes from an action"
{
    var allocator = std.testing.allocator;

    var action = try CharacterData.ActionProperties.Init(allocator);
    defer action.VulnerableHitboxGroups.deinit();

    try action.VulnerableHitboxGroups.append(try CharacterData.HitboxGroup.Init(allocator));

    action.VulnerableHitboxGroups.items[0].StartFrame = 0;
    action.VulnerableHitboxGroups.items[0].Duration = 50;

    try action.VulnerableHitboxGroups.items[0].HitBoxes.append(CharacterData.Hitbox{.Top     = 500,
                                                                                    .Bottom  = 0,
                                                                                    .Left    = -500,
                                                                                    .Right   = 500});
    defer action.VulnerableHitboxGroups.items[0].HitBoxes.deinit();

    var hitboxPool : [10]CharacterData.Hitbox = [_]CharacterData.Hitbox{.{}} ** 10;

    const frame = 5;
    const position = Math.IntVector2{ .x = 200, .y = 400};
    const count = GetVulerableBoxes(hitboxPool[0..],action, frame, position);

    const testingBox = action.VulnerableHitboxGroups.items[0].HitBoxes.items[0];
    const hitbox = hitboxPool[0];

    try std.testing.expect(count == 1);
    try std.testing.expect(action.VulnerableHitboxGroups.items[0].IsActiveOnFrame(frame));
    
    try std.testing.expect(hitbox.Top == position.y + testingBox.Top );
    try std.testing.expect(hitbox.Bottom == position.y + testingBox.Bottom);
    try std.testing.expect(hitbox.Left == position.x + testingBox.Left);
    try std.testing.expect(hitbox.Right == position.x + testingBox.Right);
}
