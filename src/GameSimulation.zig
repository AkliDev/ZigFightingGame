const Math = @import("utils/Math.zig");
 
const PhysicsComponent = struct
{   
   position: Math.IntVector2 = .{},
   velocity: Math.IntVector2 = .{},
   acceleration: Math.IntVector2 = .{},
};

pub const GameState = struct
{
  frameCount: i32 = 0,
  entityCount: i32 = 5,
  physicsComponent: [10]PhysicsComponent = [_]PhysicsComponent{.{}} ** 10,
};

// Handles moving all entities which have a physics component
fn PhysicsSystem(gameState: *GameState) void
{
   var entityIndex:usize = 0;
   while(entityIndex < gameState.entityCount)
   {
      const component = &gameState.physicsComponent[entityIndex];
      //move position based on current velocity
      component.position = Math.IntVector2.Add(component.position,component.velocity);
      component.velocity = Math.IntVector2.Add(component.velocity,component.acceleration);
      entityIndex += 1;
   }
}

pub fn UpdateGame(gameState: *GameState) void
{
   PhysicsSystem(gameState);
   gameState.frameCount += 1;
   
}