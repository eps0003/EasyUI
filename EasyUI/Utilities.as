bool isMouseInBounds(Vec2f &in min, Vec2f &in max)
{
    if (!isClient()) return false;

    Vec2f mousePos = getControls().getInterpMouseScreenPos();
    return (
        mousePos.x >= min.x && mousePos.x <= max.x &&
        mousePos.y >= min.y && mousePos.y <= max.y
    );
}

bool isHovering(Component@ component)
{
    Vec2f min = component.getTruePosition();
    Vec2f max = min + component.getTrueBounds();
    return isMouseInBounds(min, max);
}

namespace GUI
{
    void DrawOutlinedRectangle(Vec2f min, Vec2f max, float thickness, SColor color)
    {
        float minX = Maths::Min(min.x, max.x);
        float minY = Maths::Min(min.y, max.y);
        float maxY = Maths::Max(min.y, max.y);
        float maxX = Maths::Max(min.x, max.x);

        GUI::DrawRectangle(min, Vec2f(minX + thickness, maxY), color); // Left
        GUI::DrawRectangle(min, Vec2f(maxX, minY + thickness), color); // Top
        GUI::DrawRectangle(Vec2f(maxX - thickness, minY), max, color); // Right
        GUI::DrawRectangle(Vec2f(minX, maxY - thickness), max, color); // Bottom
    }
}
