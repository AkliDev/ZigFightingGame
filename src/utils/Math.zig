pub const IntVector2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn Add(self: IntVector2, other: IntVector2) IntVector2
    {
        return IntVector2 {.x = self.x + other.x, .y = self.y + other.y };
    }
};

pub fn WorldToScreen(coordinate: i32) i32
{
    return @divTrunc(coordinate, 1000);
}