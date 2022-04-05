const std = @import("std");
const rl = @import("raylib");
const Math = @import("utils/Math.zig");
const GameSimulation = @import("GameSimulation.zig");

const GameObject = struct 
{
    x: i32,
    y: i32,
};

pub fn main() anyerror!void 
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Our game state
    var gameState = GameSimulation.GameState {};

    //Initializa out game object
    gameState.physicsComponent[0].position = .{.x = 400, .y = 200};
    // Main game loop
    while (!rl.WindowShouldClose()) 
    { 
        var pressingUp : bool = false;
        var pressingDown : bool = false;
        var pressingRight : bool = false;
        var pressingLeft : bool = false;

        if(rl.IsWindowFocused() and rl.IsGamepadAvailable(0))
        {
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))
            {
                // PolledInput |= static_cast<unsigned int>(InputCommand::Up);
                pressingUp = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))
            {
                // PolledInput |= static_cast<unsigned int>(InputCommand::Down);
                pressingDown = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))
            {
                // PolledInput |= static_cast<unsigned int>(InputCommand::Left);
                pressingLeft = true;
            }
            if(rl.IsGamepadButtonDown(0, rl.GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))
            {
                // PolledInput |= static_cast<unsigned int>(InputCommand::Right);
                pressingRight = true;
            }
        }     

        //Game simulation
        {
            var entity = &gameState.physicsComponent[0];
            entity.velocity = .{};
            if(pressingUp)
            {
                entity.velocity.y = -10;
            }
            if(pressingDown)
            {
                entity.velocity.y = 10;
            }
            if(pressingLeft)
            {
                entity.velocity.x = -10;
            }
            if(pressingRight)
            {
                entity.velocity.x = 10;
            }
            GameSimulation.UpdateGame(&gameState);
        }

        // Draw
        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);

        //reflects the postion of our game object
        rl.DrawCircle(gameState.physicsComponent[0].position.x,gameState.physicsComponent[0].position.y,50,rl.MAROON);

        rl.EndDrawing();
    }

    // De-Initialization
    rl.CloseWindow(); // Close window and OpenGL context
}

test "basic test" 
{
    try std.testing.expectEqual(10, 3 + 7);
}
 