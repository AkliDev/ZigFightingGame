const Math = @import("utils/Math.zig");

pub const PhysicsComponent = struct
{   
   Position: Math.IntVector2 = .{},
   Velocity: Math.IntVector2 = .{},
   Acceleration: Math.IntVector2 = .{},
};

pub const HitEvent = struct
{
    Attacker: usize,
    Defender: usize,
};

const MAX_HIT_EVENTS_PER_ENTITY = 10;
pub const HitEventComponent = struct
{
   Events: [MAX_HIT_EVENTS_PER_ENTITY]HitEvent = [MAX_HIT_EVENTS_PER_ENTITY] **.{.Attacker = 0, .Defender = 0},
   EventCount: usize = 0,
};