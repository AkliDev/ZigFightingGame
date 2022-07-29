const std = @import("std");
const Component = @import("../Component.zig");
const Input = @import("../Input.zig");

// Identifies common character states
pub const CombatStateID = enum(u32)
{
    Standing,
    Crouching,
    WalkingForward,
    WalkingBackwards,
    Jump,
    _
};

pub const CombatStateContext = struct
{
    Transition: bool = false,
    NextState: CombatStateID = CombatStateID.Standing,
    InputCommand: Input.InputCommand = .{},
    PhysicsComponent: ?*Component.PhysicsComponent = null
};

// Provides an inferface for combat stated to respond to various events
pub const CombatStateCallbacks = struct
{
    OnStart:    ?fn(context: *CombatStateContext) void = null,  // Called when starting an action
    OnUpdate:   ?fn(context: *CombatStateContext) void = null,  // Called every frame
    OnEnd:      ?fn(context: *CombatStateContext) void = null,  // Called when Ending an action
};

pub const CombatStateRegistery = struct
{
    const MAX_STATE = 256;
    CombatStates: [MAX_STATE]?*CombatStateCallbacks = [_]?*CombatStateCallbacks{null} ** MAX_STATE,

    pub fn RegisterCommonState(self: *CombatStateRegistery, stateID: CombatStateID, stateCallbacks: *CombatStateCallbacks) void
    {
        // assert(stateID <= lastCommonState).
        self.CombatStates[@enumToInt(stateID)] = stateCallbacks;
    }
};

// Runs and keeps track of a state machine
pub const CombatStateMachineProcessor = struct
{
    Registry: CombatStateRegistery = .{},
    CurrentState: CombatStateID = CombatStateID.Standing,
    Context: ?*CombatStateContext = null, 

    pub fn UpdateStateMachine(self: *CombatStateMachineProcessor) void
    {   
        if(self.Context) | context |
        {
            if(self.Registry.CombatStates[@enumToInt(self.CurrentState)]) | state |
            {
                if(state.OnUpdate) | OnUpdate | {OnUpdate(context);}

                if(context.Transition)
                {             
                    if(state.OnEnd) | OnEnd | {OnEnd(context);}

                    if(self.Registry.CombatStates[@enumToInt(context.NextState)]) | nextState |
                    {
                        if(nextState.OnStart) | OnStart | {OnStart(context);}
                    }

                    context.Transition = false;
                    self.CurrentState = context.NextState;            
                }
            }      
        }
    }
};

pub const TestContext = struct
{
    Base: CombatStateContext = .{},
    TestVar: bool = false,
    TestVar2: bool = false,
};

fn TestOnUpdate(context: *CombatStateContext) void
{
    const context_sub = @fieldParentPtr(TestContext, "Base", context);
    context_sub.TestVar = true;
}

test "Register a combat state" 
{
    var registry = CombatStateRegistery{};
    var testState = CombatStateCallbacks{};
    
    try std.testing.expect(registry.CombatStates[0] == null);
    registry.RegisterCommonState(CombatStateID.Standing, &testState);
    try std.testing.expect(registry.CombatStates[0] != null);
}

test "Test running a state update on a state machine processor" 
{
    var context = TestContext{};
    var processor = CombatStateMachineProcessor{.Context = &context.Base};
    var testState = CombatStateCallbacks{.OnUpdate = TestOnUpdate};
    
    processor.Registry.RegisterCommonState(CombatStateID.Standing, &testState);
    processor.UpdateStateMachine();
    try std.testing.expect(context.TestVar == true);
}

test "Test transitioning the state machine from one state to the other" 
{  
    const Dummy = struct
    {
        fn StandingOnUpdate(context: *CombatStateContext) void
        {
            context.Transition = true;
            context.NextState = CombatStateID.Jump;
        }

        fn StandingOnEnd(context: *CombatStateContext) void
        {
            const context_sub = @fieldParentPtr(TestContext, "Base", context);
            context_sub.TestVar = true;
        }

        fn JumpOnStart(context: *CombatStateContext) void
        {
            const context_sub = @fieldParentPtr(TestContext, "Base", context);
            context_sub.TestVar2 = true;
        }
    };

    var context = TestContext{};
    var processor = CombatStateMachineProcessor{.Context = &context.Base};
    var standingCallbakcs = CombatStateCallbacks{.OnUpdate = Dummy.StandingOnUpdate, .OnEnd = Dummy.StandingOnEnd};
    var jumpCallbakcs = CombatStateCallbacks{.OnStart = Dummy.JumpOnStart};

    processor.Registry.RegisterCommonState(CombatStateID.Standing, &standingCallbakcs);
    processor.Registry.RegisterCommonState(CombatStateID.Jump, &jumpCallbakcs);

    processor.UpdateStateMachine();
    try std.testing.expect(context.Base.Transition == false);
    try std.testing.expectEqual(processor.CurrentState, CombatStateID.Jump);
    try std.testing.expect(context.TestVar == true);
    try std.testing.expect(context.TestVar2 == true);
}