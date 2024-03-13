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

// For a list of sizes, determine which sizes exceed their minimum
// size and distribute the excess to the other sizes. If all
// excess has been distributed or if the minimum sizes make it
// impossible to distribute the excess, terminate the recursion.
float[] distributeExcess(float[] sizes, float[] minSizes)
{
    uint count = sizes.size();

    // Accumulate excess size that needs redistributing
    float excess = 0.0f;
    uint excessCount = 0;
    uint oversizeCount = 0;

    for (uint i = 0; i < count; i++)
    {
        float size = sizes[i];
        float minSize = minSizes[i];

        if (minSize > size)
        {
            excess += minSize - size;
            excessCount++;
        }

        if (size >= minSize)
        {
            oversizeCount++;
        }
    }

    // All excess has been distributed or all sizes are oversized
    if (excessCount == 0 || oversizeCount == count)
    {
        return sizes;
    }

    // Redistribute excess size
    float dividedExcess = excess / (count - excessCount);

    for (uint i = 0; i < count; i++)
    {
        float size = sizes[i];
        float minSize = minSizes[i];

        if (minSize > size)
        {
            sizes[i] = minSize;
        }
        else
        {
            sizes[i] -= dividedExcess;
        }
    }

    // Recurse
    return distributeExcess(sizes, minSizes);
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
