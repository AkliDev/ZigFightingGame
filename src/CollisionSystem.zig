const std = @import("std");
const Math = @import("utils/Math.zig");
const GameSimulation = @import("GameSimulation.zig");
const CharacterData = @import("CharacterData.zig");
const Component = @import("Component.zig");

fn DoHitboxesOverlap(a: CharacterData.Hitbox, b: CharacterData.Hitbox) bool
{
   const IsNotOverLapping = (a.Left > b.Right) or
                            (b.Left > a.Right) or
                            (a.Bottom > b.Top) or
                            (b.Top > a.Bottom);
   return !IsNotOverLapping;

}

fn TranslateHitBox(hitbox: CharacterData.Hitbox, offset: Math.IntVector2) CharacterData.Hitbox
{
   return CharacterData.Hitbox{  .Top     = hitbox.Top + offset.y,
                                 .Bottom  = hitbox.Bottom + offset.y,
                                 .Left    = hitbox.Left + offset.x,
                                 .Right   = hitbox.Right + offset.x};
}

fn GetActiveAttackHitboxes(gameState: *GameSimulation.GameState, entity: usize) ?*CharacterData.HitboxGroup
{
    _ = gameState;
    _ = entity;
    //if(gameState.gameData) |gameData|
    //{
    //    gameData.CharacterProperties[entity].
    //}


    return null;
}

const ScratchHitboxSet = struct
{
    HitboxStore: [10]CharacterData.Hitbox,
    HitBoxes: []CharacterData.Hitbox,
};

const CollisionSystem = struct
{
    AttackerEntityBoxes: std.ArrayList(ScratchHitboxSet),
    DefenderEntityBoxes: std.ArrayList(ScratchHitboxSet),

    fn Init(allocator: std.mem.Allocator) !CollisionSystem
    {
        var attacker = try std.ArrayList(ScratchHitboxSet).initCapacity(allocator, 10);
        var defender = try std.ArrayList(ScratchHitboxSet).initCapacity(allocator, 10);
        return CollisionSystem
        {
            .AttackerEntityBoxes = attacker,
            .DefenderEntityBoxes = defender,
        };     
    }
    
    fn Execute(self: CollisionSystem, gameState: *GameSimulation.GameState) void
    {
        _ = gameState;

        // Preprocessing step. Generate hitboxes used to check collision
        //var entity: usize = 0;
        //while(entity < gameState.entityCount)
        //{
        //    const entityOffset = gameState.PhysicsComponents[entity].Position;
        //    // Get all active attack hitboxes and offet them.
        //    // GetActiveAttackHitboxes(entity);
        //    TranslateHitBox(hitbox, entityOffset);
        //    entity+=1;
        //}

        for(self.AttackerEntityBoxes.items) |attackBoxes, attackerIndex |
        {
            for(attackBoxes.HitBoxes) | attackBox |
            {
                for(self.DefenderEntityBoxes.items) | vulnerableBoxes, defenderIndex |
                {
                    //Don't check an attacker against itself
                    if(attackerIndex == defenderIndex)
                    {
                        continue;
                    }            

                    for(vulnerableBoxes.HitBoxes) | vulnerableBox |
                    {   
                        if(DoHitboxesOverlap(attackBox, vulnerableBox))
                        {
                            //Generate Hit event.
                        }
                    }
                }
            }
        }
    }

    //fn PrepareHitbox(self: CollisionSystem, gameState: *GameSimulation.GameState ) void
    //{
    //    
    //}
};

test "Initializing the collision system" 
{
    var arenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var collisionSystem : CollisionSystem = try CollisionSystem.Init(arenaAllocator.allocator());

    try std.testing.expect(collisionSystem.AttackerEntityBoxes.capacity == 10);
    try std.testing.expect(collisionSystem.AttackerEntityBoxes.items.len == 0);

    try std.testing.expect(collisionSystem.DefenderEntityBoxes.capacity == 10);
    try std.testing.expect(collisionSystem.DefenderEntityBoxes.items.len == 0);
}

test "Test clearing out scratch hitbox data each frame" 
{
    var arenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var collisionSystem : CollisionSystem = try CollisionSystem.Init(arenaAllocator.allocator());

    var allocator = arenaAllocator.allocator();

    // Our game state
    var gameState = GameSimulation.GameState {.Allocator = allocator};
    gameState.Init();

    if(gameState.GameData) | *gameData |
    {
        var character = try CharacterData.CharacterProperties.Init(allocator);
        //Add a test character
        try gameData.Characters.append(character);
    }

    // Check to see if hitboxes are staged
    //collisionSystem.PrepareHitbox(&gameState);

    try std.testing.expect(collisionSystem.AttackerEntityBoxes.capacity == 2);
    try std.testing.expect(collisionSystem.AttackerEntityBoxes.items.len == 4);

    //Run system once
    collisionSystem.Execute(&gameState);
}