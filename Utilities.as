bool isMouseInBounds(Vec2f min, Vec2f max)
{
    Vec2f mousePos = getControls().getInterpMouseScreenPos();
    return (
        mousePos.x >= min.x && mousePos.x <= max.x &&
        mousePos.y >= min.y && mousePos.y <= max.y
    );
}
