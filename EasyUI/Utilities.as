bool isMouseInBounds(Vec2f &in min, Vec2f &in max)
{
    Vec2f mousePos = getControls().getInterpMouseScreenPos();
    return (
        mousePos.x >= min.x && mousePos.x <= max.x &&
        mousePos.y >= min.y && mousePos.y <= max.y
    );
}

namespace GUI
{
    void DrawOutlinedRectangle(Vec2f min, Vec2f max, float thickness, SColor color)
    {
        GUI::DrawRectangle(min, Vec2f(min.x + thickness, max.y), color); // Left
        GUI::DrawRectangle(min, Vec2f(max.x, min.y + thickness), color); // Top
        GUI::DrawRectangle(Vec2f(max.x - thickness, min.y), max, color); // Right
        GUI::DrawRectangle(Vec2f(min.x, max.y - thickness), max, color); // Bottom
    }
}