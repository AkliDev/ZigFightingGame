const std = @import("std");
const StateMachine = @import("StateMachine.zig");

// Standing State
pub const Standing = struct 
{
    pub fn OnStart(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("Standing.OnStart()\n", .{});
    }

    pub fn OnUpdate(context: *StateMachine.CombatStateContext) void
    {
        _= context;

        if(context.PhysicsComponent) | physicsComponent |
        {
            physicsComponent.Velocity.x = 0;
        }

        if(context.InputCommand.Right == true)
        {
            context.Transition = true;
            context.NextState = StateMachine.CombatStateID.WalkingForward;
        }
    }

    pub fn OnEnd(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("Standing.OnEnd()\n", .{});
    }
};

// WalkingForward State
pub const WalkingForward = struct 
{
    pub fn OnStart(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("WalkingForward.OnStart()\n", .{});
    }

    pub fn OnUpdate(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        if(context.PhysicsComponent) | physicsComponent |
        {
            physicsComponent.Velocity.x = 5000;
        }

        if(context.InputCommand.Right == false)
        {
            context.Transition = true;
            context.NextState = StateMachine.CombatStateID.Standing;
        }
    }

    pub fn OnEnd(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("WalkingForward.OnEnd()\n", .{});
    }
};

// Crouching State
pub const Crouching = struct 
{
    pub fn OnStart(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("Crouching.OnStart()\n", .{});
    }

    pub fn OnUpdate(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("Crouching.OnUpdate()\n", .{});
    }

    pub fn OnEnd(context: *StateMachine.CombatStateContext) void
    {
        _= context;
        std.debug.print("Crouching.OnEnd()\n", .{});
    }
};