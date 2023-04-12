bool isMouseInBounds(Vec2f &in min, Vec2f &in max)
{
    Vec2f mousePos = getControls().getInterpMouseScreenPos();
    return (
        mousePos.x >= min.x && mousePos.x <= max.x &&
        mousePos.y >= min.y && mousePos.y <= max.y
    );
}
