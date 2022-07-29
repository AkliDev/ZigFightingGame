const std = @import("std");
const Math = @import("utils/Math.zig");
const Component = @import("Component.zig");
const StateMachine = @import("ActionStates/StateMachine.zig");
const CommonStates = @import("ActionStates/CommonStates.zig");
const Input = @import("Input.zig");
const CharacterData = @import("CharacterData.zig");

const InputComponent = struct
{
   InputCommand: Input.InputCommand = .{},
};

const StateMachineComponent = struct
{
   Context: StateMachine.CombatStateContext = .{},
   StateMachine: StateMachine.CombatStateMachineProcessor = .{},
};

//For now our only test state is a global constant. Need to move this to somehwere character specific data is stored.
var StandingCallbakcs = StateMachine.CombatStateCallbacks{        .OnStart = CommonStates.Standing.OnStart, 
                                                                  .OnUpdate = CommonStates.Standing.OnUpdate,
                                                                  .OnEnd = CommonStates.Standing.OnEnd};

var WalkingForwardCallbakcs = StateMachine.CombatStateCallbacks{  .OnStart = CommonStates.WalkingForward.OnStart, 
                                                                  .OnUpdate = CommonStates.WalkingForward.OnUpdate,
                                                                  .OnEnd = CommonStates.WalkingForward.OnEnd};

pub const GameData = struct
{
   HitboxGroup: CharacterData.HitboxGroup, //TODO: temp data, remove.
   Characters: std.ArrayList(CharacterData.CharacterProperties),
   //CharacterProperties: [10]CharacterData.CharacterProperties,
};

pub fn InitializeGameData(allocator: std.mem.Allocator) GameData 
{
   var gameData = GameData
   {    
      .HitboxGroup = CharacterData.HitboxGroup
      {
         .HitBoxes = std.ArrayList(CharacterData.Hitbox).init(allocator)
      },

      .Characters = std.ArrayList(CharacterData.CharacterProperties).init(allocator)
   };
   
   gameData.HitboxGroup.HitBoxes.append(CharacterData.Hitbox
   {
      .Top     = 200,
      .Bottom  = 0,
      .Left    = 300,
      .Right   = 600 
   }) catch unreachable;

   return gameData;
}

pub const GameState = struct
{
   FrameCount: i32 = 0,
   EntityCount: i32 = 1,
   PhysicsComponents: [10]Component.PhysicsComponent = [_]Component.PhysicsComponent{.{}} ** 10,
   StateMachineComponents: [10]StateMachineComponent = [_]StateMachineComponent{.{}} ** 10,

   InputComponents: [2]InputComponent = [_]InputComponent{.{}} ** 2, 

   Allocator: std.mem.Allocator,
   GameData: ?GameData = null,
   
   pub fn Init(self: *GameState) void 
   {
      //Game data initialization
      self.GameData = InitializeGameData(self.Allocator);

      //testing initialization a single entity
      self.StateMachineComponents[0].Context.PhysicsComponent = &self.PhysicsComponents[0];
      self.StateMachineComponents[0].StateMachine.Context = &self.StateMachineComponents[0].Context;
      self.StateMachineComponents[0].StateMachine.Registry.RegisterCommonState(StateMachine.CombatStateID.Standing, &StandingCallbakcs);
      self.StateMachineComponents[0].StateMachine.Registry.RegisterCommonState(StateMachine.CombatStateID.WalkingForward, &WalkingForwardCallbakcs);
   }
};

// Handles moving all entities which have a physics component
fn PhysicsSystem(gameState: *GameState) void
{
   var entityIndex:usize = 0;
   while(entityIndex < gameState.EntityCount)
   {
      const component = &gameState.PhysicsComponents[entityIndex];
      //move position based on current velocity
      component.Position = component.Position.Add(component.Velocity);
      component.Velocity = component.Velocity.Add(component.Acceleration);
      entityIndex += 1;
   }
}

fn ActionSystem(gameState: *GameState) void
{
   var entityIndex:usize = 0;
   while(entityIndex < gameState.EntityCount)
   {
      const component = &gameState.StateMachineComponents[entityIndex];
      component.StateMachine.UpdateStateMachine();
      entityIndex += 1;
   }
}

fn InputCommandSystem(gameState: *GameState) void
{
   gameState.StateMachineComponents[0].Context.InputCommand = gameState.InputComponents[0].InputCommand;
}

test "Testing setting up game data" 
{
   var arenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
   var allocator = arenaAllocator.allocator();
   var gameData = InitializeGameData(allocator);

   try std.testing.expect(gameData.HitboxGroup.HitBoxes.items.len == 1);
   try std.testing.expect(gameData.HitboxGroup.HitBoxes.items[0].Left == 300);
   try std.testing.expect(gameData.HitboxGroup.HitBoxes.items[0].Right == 600);
}

pub fn UpdateGame(gameState: *GameState) void
{
   InputCommandSystem(gameState);

   ActionSystem(gameState);
   PhysicsSystem(gameState);
   gameState.FrameCount += 1; 
}