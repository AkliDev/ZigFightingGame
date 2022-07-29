const std = @import("std");
const rl = @import("raylib");
const Math = @import("utils/Math.zig");
const GameSimulation = @import("GameSimulation.zig");

pub fn GameLoop() void
{
    var arenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // Gree all memory used by all the persistent stored memory at once
    
    defer arenaAllocator.deinit();
    
    // Our game state
    var gameState = GameSimulation.GameState {.Allocator = arenaAllocator.allocator()};
    gameState.Init();

    //Initializa out game object
    gameState.PhysicsComponents[0].Position = .{.x = 400 * 1000, .y = 200 * 1000};
    // Main game loop
    while (!rl.WindowShouldClose()) 
    { 
        //Reset input to not held down before polling
        gameState.InputComponents[0].InputCommand.Reset();

        if(rl.IsWindowFocused() and rl.IsGamepadAvailable(0))
        {
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))
            {
                gameState.InputComponents[0].InputCommand.Up = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))
            {
                gameState.InputComponents[0].InputCommand.Down = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))
            {
               gameState.InputComponents[0].InputCommand.Left = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))
            {
                gameState.InputComponents[0].InputCommand.Right = true;
            }
        }     

        //Game simulation
        GameSimulation.UpdateGame(&gameState);
        
        // Draw
        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);

        const screenX = Math.WorldToScreen(gameState.PhysicsComponents[0].Position.x);
        const screenY = Math.WorldToScreen(gameState.PhysicsComponents[0].Position.y);
        //reflects the postion of our game object
        rl.DrawCircle(screenX,screenY,50,rl.MAROON);

        if(gameState.GameData) | gameData |
        {
            
            const hitbox = gameData.HitboxGroup.HitBoxes.items[0];
            rl.DrawRectangleLines(hitbox.Left,hitbox.Top,hitbox.Right - hitbox.Left, hitbox.Top - hitbox.Bottom,rl.RED);
        }

        rl.EndDrawing();
    }    
}